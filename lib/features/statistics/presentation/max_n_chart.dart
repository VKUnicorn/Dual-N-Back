import 'dart:math';

import 'package:dual_n_back/features/statistics/application/stats_metrics.dart';
import 'package:dual_n_back/features/statistics/domain/saved_session.dart';
import 'package:dual_n_back/features/statistics/domain/stats_period.dart';
import 'package:dual_n_back/features/statistics/presentation/chart_card.dart';
import 'package:dual_n_back/features/statistics/presentation/chart_helpers.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MaxNChart extends StatefulWidget {
  const MaxNChart({
    required this.period,
    required this.range,
    required this.sessions,
    required this.priorValue,
    super.key,
  });

  final StatsPeriod period;
  final StatsRange range;
  final List<SavedSession> sessions;

  /// N of the last session before `range.start`, or 0 when none. Seeds
  /// the forward-fill the same way the accuracy chart's `priorValue`
  /// does.
  final double priorValue;

  @override
  State<MaxNChart> createState() => _MaxNChartState();
}

class _MaxNChartState extends State<MaxNChart> {
  int? _selected;

  @override
  void didUpdateWidget(MaxNChart old) {
    super.didUpdateWidget(old);
    if (old.period != widget.period || old.range.start != widget.range.start) {
      _selected = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final buckets = bucketize(widget.period, widget.range, widget.sessions);
    // Forward-fill seeded with the prior session's N — see the accuracy
    // chart's comment for the rationale.
    final realIndices = <int>{};
    final spots = <FlSpot>[];
    var lastSeen = widget.priorValue;
    for (var i = 0; i < buckets.length; i++) {
      if (buckets[i].sessions > 0) {
        lastSeen = buckets[i].maxN.toDouble();
        realIndices.add(i);
      }
      spots.add(FlSpot(i.toDouble(), lastSeen));
    }
    // `priorValue` factors into the y-axis ceiling so the seeded prefix
    // isn't accidentally clipped above maxY.
    final maxY = max(
      widget.priorValue.ceil(),
      buckets.fold<int>(2, (a, b) => max(a, b.maxN)),
    );
    final barData = LineChartBarData(
      spots: spots,
      color: theme.colorScheme.tertiary,
      barWidth: 3,
      dotData: FlDotData(
        // Hide dots on forward-filled segments — see avg_accuracy_chart
        // for the rationale.
        getDotPainter: (spot, _, _, index) => realIndices.contains(index)
            ? FlDotCirclePainter(
                radius: 3,
                color: theme.colorScheme.tertiary,
              )
            : FlDotCirclePainter(
                radius: 0,
                color: Colors.transparent,
              ),
      ),
    );

    return ChartCard(
      title: l.statisticsChartMaxN,
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: (maxY + 1).toDouble(),
            gridData: const FlGridData(
              drawVerticalLine: false,
              horizontalInterval: 1,
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: 1,
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
              bottomTitles: bottomTitles(context, widget.period, widget.range),
            ),
            borderData: FlBorderData(show: false),
            lineTouchData: toggleTouchData(
              theme: theme,
              selected: _selected,
              onTap: (i) => setState(() => _selected = i),
              format: (i, y) =>
                  '${bucketDateLabel(context, widget.period, widget.range, i)}: ${y.round()}',
            ),
            showingTooltipIndicators: _selected == null
                ? const []
                : [
                    ShowingTooltipIndicators([
                      LineBarSpot(barData, 0, barData.spots[_selected!]),
                    ]),
                  ],
            lineBarsData: [barData],
          ),
        ),
      ),
    );
  }
}
