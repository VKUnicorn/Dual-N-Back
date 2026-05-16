import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/game/presentation/game_screen.dart';
import 'package:dual_n_back/features/statistics/application/stats_metrics.dart';
import 'package:dual_n_back/features/statistics/domain/saved_session.dart';
import 'package:dual_n_back/features/statistics/domain/stats_period.dart';
import 'package:dual_n_back/features/statistics/presentation/chart_card.dart';
import 'package:dual_n_back/features/statistics/presentation/chart_helpers.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// One line per active channel — same forward-fill / tap-tooltip
/// approach as the other line charts, but the legend chip row up top
/// labels each colour.
class PerChannelAccuracyChart extends StatefulWidget {
  const PerChannelAccuracyChart({
    required this.period,
    required this.range,
    required this.sessions,
    required this.activeChannels,
    required this.priorValues,
    super.key,
  });

  final StatsPeriod period;
  final StatsRange range;
  final List<SavedSession> sessions;
  final List<ChannelType> activeChannels;
  final Map<ChannelType, double> priorValues;

  @override
  State<PerChannelAccuracyChart> createState() =>
      _PerChannelAccuracyChartState();
}

class _PerChannelAccuracyChartState extends State<PerChannelAccuracyChart> {
  int? _selected;

  @override
  void didUpdateWidget(PerChannelAccuracyChart old) {
    super.didUpdateWidget(old);
    if (old.period != widget.period || old.range.start != widget.range.start) {
      _selected = null;
    }
  }

  Color _colorFor(ThemeData theme, ChannelType c) {
    // Hard-coded for legibility — relying on the theme's primary /
    // secondary / tertiary slots produced too-similar shades on the
    // default Material 3 palette.
    switch (c) {
      case ChannelType.position:
        return const Color(0xFFE53935); // red 600
      case ChannelType.audio:
        return const Color(0xFF43A047); // green 600
      case ChannelType.color:
        return const Color(0xFFFB8C00); // orange 600
      case ChannelType.shape:
        return const Color(0xFF8E24AA); // purple 600
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final buckets = bucketize(widget.period, widget.range, widget.sessions);
    // Build one forward-filled line per active channel.
    final perChannelSpots = <ChannelType, List<FlSpot>>{};
    final perChannelReal = <ChannelType, Set<int>>{};
    for (final ch in widget.activeChannels) {
      final spots = <FlSpot>[];
      final real = <int>{};
      var lastSeen = widget.priorValues[ch] ?? 0;
      for (var i = 0; i < buckets.length; i++) {
        final w = buckets[i].channelAccWeight[ch] ?? 0;
        if (w > 0) {
          lastSeen = (buckets[i].channelAccSum[ch]! / w) * 100;
          real.add(i);
        }
        spots.add(FlSpot(i.toDouble(), lastSeen));
      }
      perChannelSpots[ch] = spots;
      perChannelReal[ch] = real;
    }

    final bars = <LineChartBarData>[
      for (final ch in widget.activeChannels)
        LineChartBarData(
          spots: perChannelSpots[ch]!,
          isCurved: true,
          color: _colorFor(theme, ch),
          barWidth: 2.5,
          dotData: FlDotData(
            getDotPainter: (spot, _, _, index) =>
                perChannelReal[ch]!.contains(index)
                    ? FlDotCirclePainter(radius: 2.5, color: _colorFor(theme, ch))
                    : FlDotCirclePainter(radius: 0, color: Colors.transparent),
          ),
        ),
    ];

    return ChartCard(
      title: l.statisticsChartChannelAccuracy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend row: a coloured square + the localised channel name.
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              for (final ch in widget.activeChannels)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _colorFor(theme, ch),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      channelLabel(context, ch),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
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
                  bottomTitles: bottomTitles(
                    context,
                    widget.period,
                    widget.range,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: false,
                  touchCallback: (event, response) {
                    if (event is! FlTapUpEvent) return;
                    final s = response?.lineBarSpots;
                    if (s == null || s.isEmpty) return;
                    final tapped = s.first.spotIndex;
                    setState(() {
                      _selected = _selected == tapped ? null : tapped;
                    });
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) =>
                        theme.colorScheme.secondaryContainer,
                    getTooltipItems: (spots) {
                      // Tooltip shows the date once on top, then a line
                      // per channel — matches the way the chart layers
                      // multiple measurements at the same x.
                      String? dateLine;
                      final items = <LineTooltipItem>[];
                      for (final spot in spots) {
                        if (dateLine == null) {
                          dateLine = bucketDateLabel(
                            context,
                            widget.period,
                            widget.range,
                            spot.spotIndex,
                          );
                          items.add(
                            LineTooltipItem(
                              '$dateLine\n'
                              '${channelLabel(context, widget.activeChannels[spot.barIndex])}: ${spot.y.round()}%',
                              TextStyle(
                                color: theme.colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        } else {
                          items.add(
                            LineTooltipItem(
                              '${channelLabel(context, widget.activeChannels[spot.barIndex])}: ${spot.y.round()}%',
                              TextStyle(
                                color: theme.colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                      }
                      return items;
                    },
                  ),
                ),
                showingTooltipIndicators: _selected == null
                    ? const []
                    : [
                        ShowingTooltipIndicators([
                          for (var i = 0; i < bars.length; i++)
                            LineBarSpot(bars[i], i, bars[i].spots[_selected!]),
                        ]),
                      ],
                lineBarsData: bars,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
