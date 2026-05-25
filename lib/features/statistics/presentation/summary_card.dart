import 'package:dual_n_back/features/statistics/application/stats_metrics.dart';
import 'package:dual_n_back/features/statistics/domain/stats_period.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 2×2 grid of summary tiles shown above the charts.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    required this.summary,
    required this.period,
    this.isRestDay = false,
    super.key,
  });

  final PeriodSummary summary;
  final StatsPeriod period;

  /// Day mode only: the displayed day is a configured rest day. When
  /// true, the "Daily goal" tile shows the rest-day label instead of
  /// the "{played}/{goal}" counter, mirroring the home-screen badge.
  final bool isRestDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final numFmt = NumberFormat.decimalPattern(locale);

    final isDay = period == StatsPeriod.day;
    final tiles = <SummaryTile>[
      SummaryTile(
        label: l.statisticsSummaryBestSession,
        value: summary.bestSession == null
            ? l.statisticsSummaryNone
            // Day mode: drop the date (the period header already shows
            // it, repeating inside the card is just noise).
            : isDay
                ? l.statisticsSummaryBestSessionValueShort(
                    summary.bestSession!.session.n,
                    (summary.bestAccuracy * 100).round(),
                  )
                : l.statisticsSummaryBestSessionValue(
                    summary.bestSession!.session.n,
                    (summary.bestAccuracy * 100).round(),
                    DateFormat.MMMd(locale).format(
                      summary.bestSession!.session.startedAt,
                    ),
                  ),
      ),
      SummaryTile(
        label: l.statisticsSummaryTotalTrials,
        value: summary.totalTrials == 0
            ? l.statisticsSummaryNone
            : numFmt.format(summary.totalTrials),
      ),
      SummaryTile(
        label: l.statisticsSummaryTrainingTime,
        value: _formatDuration(context, summary.totalTrainingMs),
      ),
      SummaryTile(
        label: l.statisticsSummaryDailyGoal,
        // Day mode: show "{played}/{goal}" — a direct read on today's
        // progress. Multi-day modes keep the "X days achieved out of Y
        // (Z%)" rate aggregation.
        value: isDay
            ? (isRestDay
                ? l.homeRestDayLabel
                : l.homeDailyProgress(
                    summary.sessionsInPeriod,
                    summary.dailyGoal,
                  ))
            : summary.totalDays == 0
                ? l.statisticsSummaryNone
                : l.statisticsSummaryDailyGoalValue(
                    summary.daysAchievedGoal,
                    summary.totalDays,
                    ((summary.daysAchievedGoal / summary.totalDays) * 100)
                        .round(),
                  ),
      ),
      if (isDay) ...[
        // Day-mode additions: the line charts collapse to a single value
        // each (one bucket = one day), so we surface the most useful
        // ones here instead of rendering near-useless 1-point plots.
        // (Per-channel accuracy and average d′ are intentionally
        // omitted — they were too noisy to read at this granularity.)
        SummaryTile(
          label: l.statisticsChartAvgAccuracy,
          value: summary.sessionsInPeriod == 0
              ? l.statisticsSummaryNone
              : '${(summary.averageAccuracy * 100).round()}%',
        ),
        SummaryTile(
          label: l.statisticsChartMaxN,
          value: summary.maxN == 0
              ? l.statisticsSummaryNone
              : 'N${summary.maxN}',
        ),
      ],
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.statisticsSummaryTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            // Two rows × two columns. Wrap is used so very narrow phones
            // (or RTL/font-zoom contexts) collapse to a single column
            // without the layout overflowing.
            LayoutBuilder(
              builder: (context, constraints) {
                final cellWidth = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final t in tiles)
                      SizedBox(width: cellWidth, child: t),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(BuildContext context, int ms) {
    final l = AppLocalizations.of(context);
    if (ms <= 0) return l.statisticsSummaryNone;
    final totalMinutes = (ms / 60000).floor();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return l.statisticsSummaryMinutes(minutes);
    return l.statisticsSummaryHoursMinutes(hours, minutes);
  }
}

class SummaryTile extends StatelessWidget {
  const SummaryTile({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
