import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/settings/application/settings_notifier.dart';
import 'package:dual_n_back/features/settings/domain/preset.dart';
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

  /// Selected training-profile filter. `null` = all profiles (no filter).
  /// Matched against `Session.profileId`. Reset to `null` automatically
  /// when the selected id no longer appears in the history (e.g. after a
  /// clear / import).
  String? _profileFilterId;

  /// One [ExpansibleController] + [GlobalKey] per session id, lazily
  /// allocated on first focus. The controller lets us call `.expand()`
  /// programmatically; the key gives us a BuildContext under the
  /// ListView so [Scrollable.ensureVisible] knows where to scroll.
  ///
  /// We keep these maps alive for the lifetime of the screen — sessions
  /// are bounded by the visible period and the maps reset on hot-reload
  /// (when the State is recreated). No explicit eviction needed.
  final Map<int, ExpansibleController> _expandControllers = {};
  final Map<int, GlobalKey> _tileKeys = {};

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

  /// Ensures every visible session has a controller + key in the maps,
  /// so the corresponding `SessionTile` is built with both from the
  /// very first frame. Pre-allocating avoids the alternative race —
  /// where the controller is created lazily on tap, the SessionTile
  /// rebuilds with a brand-new `key` (forcing element replacement),
  /// and the controller hasn't been attached to its `ExpansibleState`
  /// by the time the post-frame callback fires.
  void _ensureSessionHandles(List<SavedSession> sessions) {
    for (final s in sessions) {
      _expandControllers.putIfAbsent(
        s.session.id,
        ExpansibleController.new,
      );
      _tileKeys.putIfAbsent(s.session.id, GlobalKey.new);
    }
  }

  /// Animates the scrollable so the widget tagged by [key] is brought
  /// into view at ~10% from the top. Extracted into its own method so
  /// the BuildContext lookup happens synchronously — calling it from a
  /// post-delay callback avoids the `use_build_context_synchronously`
  /// lint that fires when a context-typed local crosses an await.
  void _scrollIntoView(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    unawaited(
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        alignment: 0.1,
      ),
    );
  }

  /// Duration of the expand animation a [SessionTile] runs after we
  /// call `controller.expand()` — ExpansionTile defaults to 200 ms,
  /// we wait a bit longer to be sure layout has fully settled before
  /// measuring the tile's render box for the scroll.
  static const Duration _expandSettleDelay = Duration(milliseconds: 260);

  /// Heatmap day-cell tap handler. Expands the matching SessionTile
  /// and, after the expand animation has had time to settle (see
  /// [_expandSettleDelay]), scrolls the now-grown tile into view via
  /// its [GlobalKey]. Scrolling BEFORE the expand finishes measures
  /// the collapsed render box and the freshly-grown content slides
  /// off screen — the "works 1-in-20" symptom.
  void _focusDaySession(SavedSession session) {
    final id = session.session.id;
    final controller = _expandControllers[id];
    final key = _tileKeys[id];
    if (controller == null || key == null) return;
    try {
      controller.expand();
    } on Object {
      // Controller wasn't attached yet — fall through; the scroll
      // below still uses the collapsed tile's position, which is
      // better than nothing.
    }
    Future<void>.delayed(_expandSettleDelay, () {
      if (!mounted) return;
      _scrollIntoView(key);
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
        data: (allSessions) {
          // Distinct training profiles present in the history, for the
          // filter dropdown. Drop a stale selection that no longer exists.
          final profiles = _profilesInHistory(allSessions, l.presetDefaultName);
          final selectedProfileId =
              profiles.any((p) => p.id == _profileFilterId)
                  ? _profileFilterId
                  : null;
          // Everything below operates on the profile-filtered set so the
          // summary, heatmap, charts and session list all agree.
          final sessions = selectedProfileId == null
              ? allSessions
              : allSessions
                  .where(
                    (s) =>
                        (s.session.profileId ?? Preset.defaultPresetId) ==
                        selectedProfileId,
                  )
                  .toList();

          final range = StatsPeriodMath.rangeFor(_period, _anchor);
          final inRange = sessions
              .where(
                (s) =>
                    !s.session.startedAt.isBefore(range.start) &&
                    s.session.startedAt.isBefore(range.end),
              )
              .toList();
          // Pre-allocate the per-session controller / key for every
          // visible tile so day-mode taps can rely on both being live
          // from the first frame the tile is built (see
          // [_focusDaySession] for the post-frame expand + scroll).
          _ensureSessionHandles(inRange);

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
              if (profiles.isNotEmpty)
                _ProfileFilterBar(
                  profiles: profiles,
                  selectedId: selectedProfileId,
                  onChanged: (id) => setState(() => _profileFilterId = id),
                ),
              const Divider(height: 1),
              Expanded(
                // SingleChildScrollView (not ListView) so every
                // [SessionTile] always has a live Element + RenderObject
                // even when scrolled off-screen — the day-mode "focus
                // session" tap relies on the GlobalKey resolving, and
                // ListView's SliverList virtualises off-screen elements
                // away, leaving the key with a null currentContext.
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    SummaryCard(
                      summary: summary,
                      period: _period,
                      isRestDay: _period == StatsPeriod.day &&
                          restDays.contains(range.start.weekday),
                    ),
                    const SizedBox(height: 16),
                    HeatmapCard(
                      period: _period,
                      range: range,
                      sessions: inRange,
                      onDaySessionTap: _focusDaySession,
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
                    // Session list is only rendered for Day.
                    // For Week / Month / Year the list can grow to hundreds of
                    // tiles, and because the screen uses
                    // SingleChildScrollView (not ListView.builder — see
                    // the comment near `child: SingleChildScrollView`
                    // above for why) every tile is built and laid out
                    // up-front, which causes severe scroll lag. The
                    // day-mode focus / scroll-to-session interaction is
                    // also only meaningful for Day mode, so hiding the
                    // section in Month / Year loses no functionality.
                    if (_period == StatsPeriod.day) ...[
                      const SizedBox(height: 24),
                      Text(
                        l.statisticsSessionsCount(inRange.length),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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
                          SessionTile(
                            key: _tileKeys[inRange[i].session.id],
                            saved: inRange[i],
                            controller:
                                _expandControllers[inRange[i].session.id],
                          ),
                        ],
                    ],
                    const SizedBox(height: 24),
                    // Debug button hidden — keep the import and widget so
                    // it can be re-enabled by uncommenting this line.
                    // const DebugFillButton(),
                    ],
                  ),
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

/// Distinct training profiles that appear in [sessions] (newest-first
/// order preserved, with the default profile pinned first). Legacy
/// sessions with a null `profileId` are treated as the default profile —
/// before profiles existed, everyone trained on the built-in "classic"
/// configuration — so they surface under that entry rather than being
/// hidden. The default profile's display name is localized via
/// [defaultName]; custom profiles use the name snapshot stored with the
/// session.
List<({String id, String name})> _profilesInHistory(
  List<SavedSession> sessions,
  String defaultName,
) {
  final seen = <String>{};
  final out = <({String id, String name})>[];
  for (final s in sessions) {
    final id = s.session.profileId ?? Preset.defaultPresetId;
    if (!seen.add(id)) continue;
    final stored = s.session.profileName;
    final name = id == Preset.defaultPresetId
        ? defaultName
        : (stored != null && stored.isNotEmpty ? stored : id);
    out.add((id: id, name: name));
  }
  // Pin the default profile to the top for a predictable order.
  final defIdx = out.indexWhere((p) => p.id == Preset.defaultPresetId);
  if (defIdx > 0) {
    out.insert(0, out.removeAt(defIdx));
  }
  return out;
}

/// Labelled dropdown that filters the statistics to a single training
/// profile (or all of them). Mirrors the dropdown style used elsewhere.
class _ProfileFilterBar extends StatelessWidget {
  const _ProfileFilterBar({
    required this.profiles,
    required this.selectedId,
    required this.onChanged,
  });

  final List<({String id, String name})> profiles;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  static const _allValue = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: DropdownMenu<String>(
        // Re-seed the selection when the profile list or active filter
        // changes (DropdownMenu caches initialSelection otherwise).
        key: ValueKey(
          '${selectedId ?? ''}|${profiles.map((p) => p.id).join(',')}',
        ),
        initialSelection: selectedId ?? _allValue,
        expandedInsets: EdgeInsets.zero,
        dropdownMenuEntries: [
          DropdownMenuEntry(value: _allValue, label: l.statisticsProfileAll),
          for (final p in profiles)
            DropdownMenuEntry(value: p.id, label: p.name),
        ],
        onSelected: (v) => onChanged(v == null || v.isEmpty ? null : v),
      ),
    );
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
