import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/game/presentation/game_screen.dart';
import 'package:dual_n_back/features/statistics/application/statistics_provider.dart';
import 'package:dual_n_back/features/statistics/application/stats_metrics.dart';
import 'package:dual_n_back/features/statistics/data/database.dart';
import 'package:dual_n_back/features/statistics/domain/saved_session.dart';
import 'package:dual_n_back/features/statistics/presentation/accuracy_color.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Expandable per-session card in the sessions list.
class SessionTile extends ConsumerWidget {
  const SessionTile({required this.saved, super.key});

  final SavedSession saved;

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
              'N${session.n}',
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_channelDisplay(context, score.channel)),
                        Text(
                          '${(score.accuracy * 100).toStringAsFixed(0)}% '
                          "·  d'=${score.dPrime.toStringAsFixed(2)}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
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
