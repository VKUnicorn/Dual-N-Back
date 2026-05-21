import 'package:dual_n_back/features/statistics/domain/stats_period.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Tap-to-toggle tooltip behaviour shared by every line chart.
///
/// fl_chart's default touch handling shows the tooltip while the finger
/// is held down. We disable that (`handleBuiltInTouches: false`) and use
/// `showingTooltipIndicators` on `LineChartData` to drive visibility from
/// our own state — tap a spot to pin it, tap again (or another spot) to
/// switch / clear.
LineTouchData toggleTouchData({
  required ThemeData theme,
  required int? selected,
  required ValueChanged<int?> onTap,
  required String Function(int index, double y) format,
}) {
  return LineTouchData(
    handleBuiltInTouches: false,
    touchCallback: (event, response) {
      if (event is! FlTapUpEvent) return;
      final spots = response?.lineBarSpots;
      if (spots == null || spots.isEmpty) return;
      final tapped = spots.first.spotIndex;
      onTap(selected == tapped ? null : tapped);
    },
    touchTooltipData: LineTouchTooltipData(
      getTooltipColor: (_) => theme.colorScheme.secondaryContainer,
      getTooltipItems: (spots) => [
        for (final spot in spots)
          LineTooltipItem(
            format(spot.spotIndex, spot.y),
            TextStyle(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    ),
  );
}

/// Localised label for the bucket at [index] of the given [period].
///
/// week  → full weekday name (e.g. "Вторник", "Tuesday")
/// month → "{month name}, {day}" (e.g. "Май, 22", "May, 22")
/// year  → full month name (e.g. "Февраль", "February")
String bucketDateLabel(
  BuildContext context,
  StatsPeriod period,
  StatsRange range,
  int index,
) {
  final locale = Localizations.localeOf(context).toString();
  String capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  switch (period) {
    case StatsPeriod.day:
      // Single-bucket period: tooltip just shows the date.
      return capitalize(DateFormat.yMMMMd(locale).format(range.start));
    case StatsPeriod.week:
      final d = range.start.add(Duration(days: index));
      return capitalize(DateFormat.EEEE(locale).format(d));
    case StatsPeriod.month:
      final day = index + 1;
      final d = DateTime(range.start.year, range.start.month, day);
      return '${capitalize(DateFormat.MMMM(locale).format(d))}, $day';
    case StatsPeriod.year:
      final d = DateTime(range.start.year, index + 1);
      return capitalize(DateFormat.MMMM(locale).format(d));
  }
}

/// Pick a sane y-axis tick interval — aim for at most ~10 ticks
/// regardless of the magnitude of [maxY], snapping to "nice" round
/// numbers (1 / 2 / 5 / 10 / 20 / 25 / 50 / 100 …).
double yInterval(int maxY) {
  if (maxY <= 0) return 1;
  // Smallest "nice" step that produces ≤ 10 ticks. Order matters: each
  // entry is checked in turn and the first that fits wins.
  const candidates = <int>[
    1, 2, 5, 10, 20, 25, 50, 100, 200, 250, 500, 1000, 2000, 5000,
  ];
  for (final c in candidates) {
    if (maxY / c <= 10) return c.toDouble();
  }
  return (maxY / 10).ceilToDouble();
}

/// Bottom (x-axis) labels that vary by period:
///   week  → Mon/Tue/... (localised, 3-char)
///   month → 1, 5, 10, 15, 20, 25, last-day
///   year  → 1..12 (numeric — short enough to fit unrotated)
AxisTitles bottomTitles(
  BuildContext context,
  StatsPeriod period,
  StatsRange range,
) {
  final theme = Theme.of(context);
  final locale = Localizations.localeOf(context).toString();

  switch (period) {
    case StatsPeriod.day:
      // Day-mode line charts are a single bucket, so no x-axis labels.
      return const AxisTitles();
    case StatsPeriod.week:
      final fmt = DateFormat.E(locale);
      return AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: 1,
          getTitlesWidget: (v, meta) {
            if (v != v.roundToDouble()) return const SizedBox.shrink();
            final i = v.toInt();
            if (i < 0 || i > 6) return const SizedBox.shrink();
            final d = range.start.add(Duration(days: i));
            return SideTitleWidget(
              meta: meta,
              child: Text(fmt.format(d), style: theme.textTheme.bodySmall),
            );
          },
        ),
      );
    case StatsPeriod.month:
      final last = range.bucketCount(StatsPeriod.month);
      return AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          interval: 1,
          getTitlesWidget: (v, meta) {
            if (v != v.roundToDouble()) return const SizedBox.shrink();
            final i = v.toInt();
            // Show 1, 5, 10, 15, 20, 25, last — keeps the axis readable.
            final day = i + 1;
            final shouldShow = day == 1 ||
                day == 5 ||
                day == 10 ||
                day == 15 ||
                day == 20 ||
                day == 25 ||
                day == last;
            if (!shouldShow) return const SizedBox.shrink();
            return SideTitleWidget(
              meta: meta,
              child: Text('$day', style: theme.textTheme.bodySmall),
            );
          },
        ),
      );
    case StatsPeriod.year:
      return AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          interval: 1,
          getTitlesWidget: (v, meta) {
            if (v != v.roundToDouble()) return const SizedBox.shrink();
            final i = v.toInt();
            if (i < 0 || i > 11) return const SizedBox.shrink();
            return SideTitleWidget(
              meta: meta,
              child: Text('${i + 1}', style: theme.textTheme.bodySmall),
            );
          },
        ),
      );
  }
}
