import 'dart:math';

import 'package:dual_n_back/features/statistics/domain/saved_session.dart';
import 'package:dual_n_back/features/statistics/presentation/chart_card.dart';
import 'package:dual_n_back/features/statistics/presentation/chart_helpers.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Bar chart of how many sessions were played at each N level inside
/// the visible period — quickly shows where the player spends most of
/// their time.
class NDistributionChart extends StatelessWidget {
  const NDistributionChart({required this.sessions, super.key});

  final List<SavedSession> sessions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);

    final counts = <int, int>{};
    for (final s in sessions) {
      counts[s.session.n] = (counts[s.session.n] ?? 0) + 1;
    }
    final levels = counts.keys.toList()..sort();
    final maxCount = counts.values.fold<int>(1, max);

    if (levels.isEmpty) {
      // Nothing to show — render the title with a small placeholder so
      // the card layout stays consistent with the other charts.
      return ChartCard(
        title: l.statisticsChartNDistribution,
        child: SizedBox(
          height: 120,
          child: Center(
            child: Text(
              l.statisticsEmptyTitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return ChartCard(
      title: l.statisticsChartNDistribution,
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            minY: 0,
            maxY: (maxCount + 1).toDouble(),
            gridData: const FlGridData(drawVerticalLine: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: yInterval(maxCount),
                  getTitlesWidget: (v, _) {
                    if (v != v.roundToDouble()) return const SizedBox.shrink();
                    return Text(
                      '${v.toInt()}',
                      style: theme.textTheme.bodySmall,
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: 1,
                  getTitlesWidget: (v, meta) {
                    final i = v.toInt();
                    if (i < 0 || i >= levels.length) {
                      return const SizedBox.shrink();
                    }
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        'N${levels[i]}',
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => theme.colorScheme.secondaryContainer,
                getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                  'N${levels[group.x]}: ${rod.toY.round()}',
                  TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < levels.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: counts[levels[i]]!.toDouble(),
                      color: theme.colorScheme.primary,
                      width: 18,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
