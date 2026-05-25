import 'dart:math';

import 'package:dual_n_back/features/statistics/application/stats_metrics.dart';
import 'package:dual_n_back/features/statistics/domain/saved_session.dart';
import 'package:dual_n_back/features/statistics/domain/stats_period.dart';
import 'package:dual_n_back/features/statistics/presentation/chart_card.dart';
import 'package:dual_n_back/features/statistics/presentation/chart_helpers.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// d′ (d-prime) line chart — sensitivity index from signal-detection
/// theory. Higher means the player tells signal from noise better,
/// independent of any tendency to over- or under-press.
class DprimeChart extends StatefulWidget {
  const DprimeChart({
    required this.period,
    required this.range,
    required this.sessions,
    required this.priorValue,
    super.key,
  });

  final StatsPeriod period;
  final StatsRange range;
  final List<SavedSession> sessions;
  final double priorValue;

  @override
  State<DprimeChart> createState() => _DprimeChartState();
}

class _DprimeChartState extends State<DprimeChart> {
  int? _selected;

  @override
  void didUpdateWidget(DprimeChart old) {
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
    final realIndices = <int>{};
    final spots = <FlSpot>[];
    var lastSeen = widget.priorValue;
    for (var i = 0; i < buckets.length; i++) {
      if (buckets[i].dpWeight > 0) {
        lastSeen = buckets[i].dpSum / buckets[i].dpWeight;
        realIndices.add(i);
      }
      spots.add(FlSpot(i.toDouble(), lastSeen));
    }
    // d′ is unbounded, but realistic values sit in 0..~4. Keep a sane
    // ceiling that grows with the data so the line isn't squashed.
    final dataMax = buckets
        .where((b) => b.dpWeight > 0)
        .map((b) => b.dpSum / b.dpWeight)
        .fold<double>(widget.priorValue, max);
    final maxY = (dataMax + 0.5).clamp(2.0, 6.0);
    final barData = LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: kLineCurveSmoothness,
      color: theme.colorScheme.primary,
      barWidth: 3,
      dotData: FlDotData(
        getDotPainter: (spot, _, _, index) => realIndices.contains(index)
            ? FlDotCirclePainter(radius: 3, color: theme.colorScheme.primary)
            : FlDotCirclePainter(radius: 0, color: Colors.transparent),
      ),
    );

    return ChartCard(
      title: l.statisticsChartDprime,
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY,
            gridData: const FlGridData(drawVerticalLine: false),
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
                  '${bucketDateLabel(context, widget.period, widget.range, i)}: ${y.toStringAsFixed(2)}',
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
