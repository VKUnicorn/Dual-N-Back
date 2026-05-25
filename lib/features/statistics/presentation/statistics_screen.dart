import 'dart:convert';
import 'dart:io';

import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/settings/application/settings_notifier.dart';
import 'package:dual_n_back/features/statistics/application/statistics_provider.dart';
import 'package:dual_n_back/features/statistics/application/stats_metrics.dart';
import 'package:dual_n_back/features/statistics/data/statistics_backup_codec.dart';
import 'package:dual_n_back/features/statistics/domain/saved_session.dart';
import 'package:dual_n_back/features/statistics/domain/stats_period.dart';
import 'package:dual_n_back/features/statistics/presentation/avg_accuracy_chart.dart';
// Kept for re-enabling the debug "fill 2 years of random data" button
// at the bottom of the statistics screen — see the commented usage below.
// ignore: unused_import
import 'package:dual_n_back/features/statistics/presentation/debug_fill_button.dart';
import 'package:dual_n_back/features/statistics/presentation/dprime_chart.dart';
import 'package:dual_n_back/features/statistics/presentation/heatmap_card.dart';
import 'package:dual_n_back/features/statistics/presentation/max_n_chart.dart';
import 'package:dual_n_back/features/statistics/presentation/n_distribution_chart.dart';
import 'package:dual_n_back/features/statistics/presentation/per_channel_accuracy_chart.dart';
import 'package:dual_n_back/features/statistics/presentation/period_header.dart';
import 'package:dual_n_back/features/statistics/presentation/session_tile.dart';
import 'package:dual_n_back/features/statistics/presentation/summary_card.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Statistics screen — orchestrates the period header, the various chart
/// widgets, the session list and the debug button. The heavy lifting
/// (aggregation, summary, individual chart rendering) lives in dedicated
/// files alongside this one; see the imports above.
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  StatsPeriod _period = StatsPeriod.day;
  // `_anchor` is any moment inside the visible period; the visible range
  // is computed from it via [StatsPeriodMath.rangeFor].
  DateTime _anchor = DateTime.now();

  void _setPeriod(StatsPeriod p) {
    setState(() {
      _period = p;
      // Always reset cursor to "current" when switching tabs (per UX spec).
      _anchor = DateTime.now();
    });
  }

  void _shift(int delta) {
    setState(() {
      _anchor = StatsPeriodMath.shift(_period, _anchor, delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(sessionsHistoryProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.statisticsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_outlined),
            tooltip: l.statisticsExportTooltip,
            onPressed: () => _exportHistory(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: l.statisticsImportTooltip,
            onPressed: () => _importHistory(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l.statisticsClearTooltip,
            onPressed: () => _confirmClear(context, ref),
          ),
        ],
      ),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(l.statisticsErrorPrefix(e.toString()))),
        data: (sessions) {
          final range = StatsPeriodMath.rangeFor(_period, _anchor);
          final inRange = sessions
              .where(
                (s) =>
                    !s.session.startedAt.isBefore(range.start) &&
                    s.session.startedAt.isBefore(range.end),
              )
              .toList();

          // Active state for nav arrows.
          final hasOlder = sessions.any(
            (s) => s.session.startedAt.isBefore(range.start),
          );
          final hasNewer = sessions.any(
            (s) => !s.session.startedAt.isBefore(range.end),
          );
          final canGoForward = hasNewer ||
              range.start.isBefore(
                StatsPeriodMath.rangeFor(_period, DateTime.now()).start,
              );

          // Most recent session strictly before the visible range — used
          // by the accuracy / max-N / d′ charts to seed their forward-fill
          // so empty leading buckets carry the player's last real value
          // rather than 0. `sessions` is sorted newest-first by the
          // repository, so this finds it in O(n) without sorting.
          SavedSession? prior;
          for (final s in sessions) {
            if (s.session.startedAt.isBefore(range.start)) {
              prior = s;
              break;
            }
          }
          final priorAcc = prior == null
              ? 0.0
              : overallAccuracy(prior.scores) * 100;
          final priorMaxN = prior?.session.n.toDouble() ?? 0;
          // Prior d′: weighted mean across the prior session's channels —
          // matches the per-bucket pooling the chart uses.
          var priorDp = 0.0;
          if (prior != null) {
            var sum = 0.0;
            var w = 0;
            for (final score in prior.scores) {
              final tw = engagedTotal(score);
              if (tw == 0) continue;
              sum += score.dPrime * tw;
              w += tw;
            }
            priorDp = w == 0 ? 0 : sum / w;
          }
          // Prior per-channel accuracy: from the most recent session
          // *containing that channel*, not necessarily the same session
          // for every channel. Walking newest-first and stopping when
          // every active channel has a value catches all of them in one
          // pass.
          final activeChannelsList = activeChannels(inRange).toList()
            ..sort((a, b) => a.index.compareTo(b.index));
          final priorChannelAcc = <ChannelType, double>{};
          for (final s in sessions) {
            if (!s.session.startedAt.isBefore(range.start)) continue;
            for (final score in s.scores) {
              for (final c in ChannelType.values) {
                if (c.name != score.channel) continue;
                priorChannelAcc.putIfAbsent(c, () => score.accuracy * 100);
              }
            }
            if (priorChannelAcc.length >= activeChannelsList.length &&
                activeChannelsList.every(priorChannelAcc.containsKey)) {
              break;
            }
          }

          final dailyGoal = ref.watch(
            settingsProvider.select((s) => s.dailyGoalSessions),
          );
          final restDays = ref.watch(
            settingsProvider.select((s) => s.restDays),
          );
          final summary = summarize(
            range,
            inRange,
            dailyGoal,
            restDays: restDays,
          );

          return Column(
            children: [
              PeriodHeader(
                period: _period,
                anchor: _anchor,
                onPeriodChanged: _setPeriod,
                onPrev: hasOlder ? () => _shift(-1) : null,
                onNext: canGoForward ? () => _shift(1) : null,
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    SummaryCard(summary: summary, period: _period),
                    const SizedBox(height: 16),
                    HeatmapCard(
                      period: _period,
                      range: range,
                      sessions: inRange,
                      onDrillDown: (period, anchor) {
                        setState(() {
                          _period = period;
                          _anchor = anchor;
                        });
                      },
                    ),
                    // Day mode collapses every multi-bucket line chart to
                    // a single value — those values surface inside the
                    // summary card instead, so the line charts are
                    // hidden here.
                    if (_period != StatsPeriod.day) ...[
                      const SizedBox(height: 16),
                      AvgAccuracyChart(
                        period: _period,
                        range: range,
                        sessions: inRange,
                        priorValue: priorAcc,
                      ),
                      const SizedBox(height: 16),
                      DprimeChart(
                        period: _period,
                        range: range,
                        sessions: inRange,
                        priorValue: priorDp,
                      ),
                      if (activeChannelsList.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        PerChannelAccuracyChart(
                          period: _period,
                          range: range,
                          sessions: inRange,
                          activeChannels: activeChannelsList,
                          priorValues: priorChannelAcc,
                        ),
                      ],
                      const SizedBox(height: 16),
                      MaxNChart(
                        period: _period,
                        range: range,
                        sessions: inRange,
                        priorValue: priorMaxN,
                      ),
                    ],
                    const SizedBox(height: 16),
                    NDistributionChart(sessions: inRange),
                    const SizedBox(height: 24),
                    Text(
                      l.statisticsSessionsCount(inRange.length),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (inRange.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            l.statisticsEmptyTitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                      )
                    else
                      for (var i = 0; i < inRange.length; i++) ...[
                        if (i == 0 ||
                            !_isSameDay(
                              inRange[i].session.startedAt,
                              inRange[i - 1].session.startedAt,
                            ))
                          _DaySectionHeader(
                            date: inRange[i].session.startedAt,
                            count: _countSessionsOnDay(
                              inRange,
                              inRange[i].session.startedAt,
                            ),
                            isFirst: i == 0,
                          ),
                        SessionTile(saved: inRange[i]),
                      ],
                    const SizedBox(height: 24),
                    // Debug button hidden — keep the import and widget so
                    // it can be re-enabled by uncommenting this line.
                    // const DebugFillButton(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Exports the full session history to a JSON file at a user-picked
  /// location. Encodes via [StatisticsBackupCodec] and writes the bytes
  /// through `flutter_file_dialog.saveFile` — the plugin's native
  /// Android side actually writes via SAF (file_picker 12-beta returns a
  /// SAF URI but then tries `File(path).writeAsBytes` on the Dart side,
  /// which fails with "No such file or directory").
  Future<void> _exportHistory(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(statisticsRepositoryProvider);
    final history = await repo.loadAll();
    if (history.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.statisticsExportEmpty)),
      );
      return;
    }
    final json = StatisticsBackupCodec.encode(history);
    final bytes = Uint8List.fromList(utf8.encode(json));
    final fileName =
        'dual_n_back_${DateFormat('dd.MM.yyyy').format(DateTime.now())}'
        '_statistics_backup.json';
    try {
      final path = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          data: bytes,
          fileName: fileName,
          mimeTypesFilter: const ['application/json'],
        ),
      );
      if (path == null) return; // user cancelled
      messenger.showSnackBar(
        SnackBar(
          content: Text(l.statisticsExportSuccess(history.length)),
        ),
      );
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.statisticsExportError(e.toString()))),
      );
    }
  }

  /// Imports a previously-exported backup file, replacing the entire
  /// current history. Shows a warning dialog up front so the user knows
  /// existing sessions will be deleted before the file picker is even
  /// invoked.
  Future<void> _importHistory(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(statisticsRepositoryProvider);
    final existingCount = (await repo.loadAll()).length;
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.statisticsImportTitle),
        content: Text(l.statisticsImportContent(existingCount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.statisticsImportConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final path = await FlutterFileDialog.pickFile(
        params: const OpenFileDialogParams(
          fileExtensionsFilter: ['json'],
          mimeTypesFilter: ['application/json'],
        ),
      );
      if (path == null) return; // user cancelled
      final source = await File(path).readAsString();
      final seeds = StatisticsBackupCodec.decode(source);
      await repo.clearAll();
      await repo.bulkInsert(seeds);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l.statisticsImportSuccess(seeds.length)),
        ),
      );
    } on BackupFormatException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.statisticsImportFormatError(e.message))),
      );
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.statisticsImportError(e.toString()))),
      );
    }
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.statisticsClearTitle),
        content: Text(l.statisticsClearContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.commonClear),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await ref.read(statisticsRepositoryProvider).clearAll();
    }
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

int _countSessionsOnDay(List<SavedSession> sessions, DateTime day) {
  var count = 0;
  for (final s in sessions) {
    if (_isSameDay(s.session.startedAt, day)) count += 1;
  }
  return count;
}

/// Section header inserted before each day's group of [SessionTile]s.
/// Format: `3 августа 2025, вторник. 23 сессии` in Russian,
/// `3 August 2025, Tuesday. 23 sessions` in English. The first character
/// is upper-cased so headers don't start lower-case in locales where
/// `intl` returns the weekday name lower-cased (e.g. Russian).
class _DaySectionHeader extends StatelessWidget {
  const _DaySectionHeader({
    required this.date,
    required this.count,
    required this.isFirst,
  });

  final DateTime date;
  final int count;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final raw = DateFormat('d MMMM yyyy, EEEE', locale).format(date);
    final dateText = raw.isEmpty
        ? raw
        : raw[0].toUpperCase() + raw.substring(1);
    final sessionsText = l.statisticsSessionPlural(count);
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 0 : 12, bottom: 4),
      child: Text(
        '$dateText. $sessionsText',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
