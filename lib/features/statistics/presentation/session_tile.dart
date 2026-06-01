import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/game/presentation/game_screen.dart';
import 'package:dual_n_back/features/statistics/application/statistics_provider.dart';
import 'package:dual_n_back/features/statistics/application/stats_metrics.dart';
import 'package:dual_n_back/features/statistics/data/database.dart';
import 'package:dual_n_back/features/statistics/domain/saved_session.dart';
import 'package:dual_n_back/features/statistics/presentation/accuracy_color.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:dual_n_back/shared/widgets/channel_breakdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Expandable per-session card in the sessions list.
///
/// [controller] lets the surrounding screen programmatically expand the
/// tile when the user taps the matching cell in the day-mode heatmap.
/// The same controller can be re-attached across rebuilds and is stable
/// across them, so it's safe to keep one per session id at the screen
/// level and pass it in.
class SessionTile extends ConsumerWidget {
  const SessionTile({
    required this.saved,
    this.controller,
    super.key,
  });

  final SavedSession saved;
  final ExpansibleController? controller;

  static final _dateFmt = DateFormat('dd.MM.yyyy HH:mm');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = saved.session;
    final overallAcc = overallAccuracy(saved.scores);
    final accColor = accuracyTierColor(theme, overallAcc);

    final l = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        controller: controller,
        // Material 3's default ExpansionTile draws hairline dividers above
        // and below the children. Override with empty borders so the tile
        // expands cleanly inside the Card.
        shape: const Border(),
        collapsedShape: const Border(),
        // "N{n}" + accuracy bubble packed into the leading slot so the
        // title row stays a normal-height single line of text — that
        // keeps the trials subtitle from getting pushed down by a
        // tall title Row, and centers the bubble vertically against
        // the title+subtitle pair instead of riding the title row.
        // mainAxisSize.min so the leading box is just wide enough for
        // both elements; ListTile centers it vertically by default.
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              nLevelLabel(saved.scores.length, session.n),
              style: TextStyle(
                color: accColor,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            const SizedBox(width: 8),
            // Overall-accuracy bubble, mirroring the result-screen gauge
            // colour scheme. Same formula as SessionScore.overallAccuracy
            // (`sum(hits) / sum(engaged)`) — see stats_metrics.dart.
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accColor.withValues(alpha: 0.18),
              ),
              child: Text(
                '${(overallAcc * 100).round()}%',
                style: TextStyle(
                  color: accColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          _dateFmt.format(session.startedAt),
          style: theme.textTheme.bodyLarge,
        ),
        subtitle: Text(
          // Show *scored* trials only — warm-ups aren't part of the
          // accuracy/d′ calculation. The "→ N{newN}" hint was removed
          // by request; the new accuracy bubble in the leading row
          // replaces the textual "{acc}% ·" prefix the subtitle used
          // to carry.
          l.statisticsTrialCountSuffix(_scoredTrials(session)),
          style: theme.textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final score in saved.scores)
                  ChannelBreakdownRow(
                    label: _channelDisplay(context, score.channel),
                    hits: score.hits,
                    misses: score.misses,
                    falseAlarms: score.falseAlarms,
                    correctRejections: score.correctRejections,
                    accuracy: score.accuracy,
                    dPrime: score.dPrime,
                  ),
                const Divider(height: 24),
                OverallAccuracyRow(
                  totalHits: saved.scores.fold<int>(0, (a, s) => a + s.hits),
                  totalEngaged: saved.scores.fold<int>(
                    0,
                    (a, s) => a + s.hits + s.misses + s.falseAlarms,
                  ),
                  overallAccuracy: overallAcc,
                ),
                if (session.newN != session.n) ...[
                  const SizedBox(height: 8),
                  _AdaptiveChangeRow(from: session.n, to: session.newN),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    tooltip: l.statisticsSessionDeleteTooltip,
                    onPressed: () => _confirmDelete(context, ref),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.statisticsSessionDeleteTitle),
        content: Text(l.statisticsSessionDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.commonDelete),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await ref
          .read(statisticsRepositoryProvider)
          .deleteSession(saved.session.id);
    }
  }

  String _channelDisplay(BuildContext context, String name) {
    for (final c in ChannelType.values) {
      if (c.name == name) return channelLabel(context, c);
    }
    return name;
  }

  /// Number of *scored* trials in [session]: persisted `totalTrials` minus
  /// the N warm-up trials at the start (which have no n-back reference).
  int _scoredTrials(Session session) {
    final scored = session.totalTrials - session.n;
    return scored < 0 ? 0 : scored;
  }
}

/// "N before → N after" line, only rendered when adaptive mode actually
/// moved the level. Hold sessions (where `newN == n`) intentionally
/// render nothing — they include both adaptive-mode holds and any
/// session played with adaptive mode off, and we can't distinguish the
/// two from persisted state.
class _AdaptiveChangeRow extends StatelessWidget {
  const _AdaptiveChangeRow({required this.from, required this.to});

  final int from;
  final int to;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = AppLocalizations.of(context);
    final advanced = to > from;
    final color = advanced ? scheme.primary : scheme.error;
    final icon = advanced ? Icons.trending_up : Icons.trending_down;
    final numberStyle = theme.textTheme.bodyMedium?.copyWith(
      color: color,
      fontWeight: FontWeight.w600,
    );
    return Row(
      children: [
        Text(
          l.statisticsSessionAdaptiveChangeLabel,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(width: 6),
        Text('$from', style: numberStyle),
        const SizedBox(width: 6),
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text('$to', style: numberStyle),
      ],
    );
  }
}
