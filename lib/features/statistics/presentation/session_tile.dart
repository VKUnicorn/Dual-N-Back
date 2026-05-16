import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/game/presentation/game_screen.dart';
import 'package:dual_n_back/features/statistics/application/statistics_provider.dart';
import 'package:dual_n_back/features/statistics/application/stats_metrics.dart';
import 'package:dual_n_back/features/statistics/data/database.dart';
import 'package:dual_n_back/features/statistics/domain/saved_session.dart';
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
    final accColor = overallAcc >= 0.8
        ? theme.colorScheme.primary
        : (overallAcc < 0.5
            ? theme.colorScheme.error
            : theme.colorScheme.tertiary);

    final l = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        // Material 3's default ExpansionTile draws hairline dividers above
        // and below the children. Override with empty borders so the tile
        // expands cleanly inside the Card.
        shape: const Border(),
        collapsedShape: const Border(),
        leading: CircleAvatar(
          backgroundColor: accColor.withValues(alpha: 0.18),
          child: Text(
            'N${session.n}',
            style: TextStyle(
              color: accColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          _dateFmt.format(session.startedAt),
          style: theme.textTheme.bodyLarge,
        ),
        subtitle: Text(
          '${(overallAcc * 100).toStringAsFixed(0)}% '
          // Show *scored* trials only — warm-ups aren't part of the
          // accuracy/d′ calculation displayed alongside.
          '· ${l.statisticsTrialCountSuffix(_scoredTrials(session))} · '
          '→ N${session.newN}',
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
