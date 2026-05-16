import 'package:dual_n_back/features/statistics/application/stats_metrics.dart';
import 'package:dual_n_back/features/statistics/domain/saved_session.dart';
import 'package:dual_n_back/features/statistics/domain/stats_period.dart';
import 'package:dual_n_back/features/statistics/presentation/chart_card.dart';
import 'package:dual_n_back/features/statistics/presentation/chart_helpers.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AvgAccuracyChart extends StatefulWidget {
  const AvgAccuracyChart({
    required this.period,
    required this.range,
    required this.sessions,
    required this.priorValue,
    super.key,
  });

  final StatsPeriod period;
  final StatsRange range;
  final List<SavedSession> sessions;

  /// Overall accuracy (0..100) of the last session before `range.start`,
  /// or 0 when there isn't one. Seeds the forward-fill so empty leading
  /// buckets show the player's last real value instead of dropping to 0.
  final double priorValue;

  @override
  State<AvgAccuracyChart> createState() => _AvgAccuracyChartState();
}

class _AvgAccuracyChartState extends State<AvgAccuracyChart> {
  int? _selected;

  @override
  void didUpdateWidget(AvgAccuracyChart old) {
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
    // Forward-fill seeded with the last value seen *outside* this range
    // (or 0 if the player never played before). After the first real
    // measurement inside the range, that value takes over.
    final realIndices = <int>{};
    final spots = <FlSpot>[];
    var lastSeen = widget.priorValue;
    for (var i = 0; i < buckets.length; i++) {
      if (buckets[i].accWeight > 0) {
        lastSeen = (buckets[i].accSum / buckets[i].accWeight) * 100;
        realIndices.add(i);
      }
      spots.add(FlSpot(i.toDouble(), lastSeen));
    }
    final barData = LineChartBarData(
      spots: spots,
      isCurved: true,
      color: theme.colorScheme.secondary,
      barWidth: 3,
      dotData: FlDotData(
        // Only mark real measurements with a dot; on forward-filled
        // segments the line continues but no dot is drawn so the user
        // can tell which buckets actually had sessions.
        getDotPainter: (spot, _, _, index) => realIndices.contains(index)
            ? FlDotCirclePainter(
                radius: 3,
                color: theme.colorScheme.secondary,
              )
            : FlDotCirclePainter(
                radius: 0,
                color: Colors.transparent,
              ),
      ),
    );

    return ChartCard(
      title: l.statisticsChartAvgAccuracy,
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 100,
            gridData: const FlGridData(
              drawVerticalLine: false,
              horizontalInterval: 25,
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 25,
                  getTitlesWidget: (v, _) => Text(
                    '${v.toInt()}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
              bottomTitles: bottomTitles(context, widget.period, widget.range),
            ),
            borderData: FlBorderData(show: false),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: 80,
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.5),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
                HorizontalLine(
                  y: 50,
                  color: theme.colorScheme.error.withValues(alpha: 0.5),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ],
            ),
            lineTouchData: toggleTouchData(
              theme: theme,
              selected: _selected,
              onTap: (i) => setState(() => _selected = i),
              format: (i, y) =>
                  '${bucketDateLabel(context, widget.period, widget.range, i)}: ${y.round()}%',
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
