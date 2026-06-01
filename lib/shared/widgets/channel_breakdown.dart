import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Per-channel signal-detection breakdown row.
///
/// Shared between the statistics session tile (drift `ChannelScore`) and
/// the game result screen (domain `ChannelScore`). Both score types expose
/// the same primitives, so this widget takes the raw values directly to
/// stay decoupled from either concrete type.
///
/// Renders the channel name + headline `hits / engaged = {acc}% · d'=…`
/// and the raw counters (hits / misses / false alarms / correct rejections
/// / engaged) underneath, so the user can reproduce the pooled overall
/// accuracy by hand.
class ChannelBreakdownRow extends StatelessWidget {
  const ChannelBreakdownRow({
    required this.label,
    required this.hits,
    required this.misses,
    required this.falseAlarms,
    required this.correctRejections,
    required this.accuracy,
    required this.dPrime,
    super.key,
  });

  final String label;
  final int hits;
  final int misses;
  final int falseAlarms;
  final int correctRejections;

  /// 0..1
  final double accuracy;
  final double dPrime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final scheme = theme.colorScheme;
    final engaged = hits + misses + falseAlarms;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.bodyMedium),
              Text(
                '$hits/$engaged = ${(accuracy * 100).toStringAsFixed(0)}% '
                "·  d'=${dPrime.toStringAsFixed(2)}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 12,
            runSpacing: 2,
            children: [
              _counter(theme, l.statHits, hits),
              _counter(theme, l.statMisses, misses),
              _counter(theme, l.statFalseAlarms, falseAlarms),
              _counter(theme, l.statCorrectRejections, correctRejections),
              _counter(theme, l.statEngaged, engaged),
            ],
          ),
        ],
      ),
    );
  }

  Widget _counter(ThemeData theme, String label, int value) => Text(
        '$label: $value',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
}

/// Pooled-accuracy summary row shown beneath the per-channel breakdowns.
/// Shows the raw fraction `hits / engaged` plus a formula hint so the
/// rounded percentage can be verified by hand.
class OverallAccuracyRow extends StatelessWidget {
  const OverallAccuracyRow({
    required this.totalHits,
    required this.totalEngaged,
    required this.overallAccuracy,
    super.key,
  });

  final int totalHits;
  final int totalEngaged;

  /// 0..1
  final double overallAccuracy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.statisticsSessionOverallLabel,
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              l.statisticsSessionOverallValue(
                totalHits,
                totalEngaged,
                (overallAccuracy * 100).round(),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l.statisticsSessionOverallFormulaHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
