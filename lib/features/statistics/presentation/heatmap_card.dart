import 'dart:math';

import 'package:dual_n_back/features/statistics/application/stats_metrics.dart';
import 'package:dual_n_back/features/statistics/domain/saved_session.dart';
import 'package:dual_n_back/features/statistics/domain/stats_period.dart';
import 'package:dual_n_back/features/statistics/presentation/accuracy_color.dart';
import 'package:dual_n_back/features/statistics/presentation/chart_card.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Calendar-style heatmap of sessions per day. The grid layout differs
/// per period:
///   week  → 7 cells in a single row, weekday labels above
///   month → calendar grid (5–6 rows × 7 cols), weekday labels above
///   year  → 12 month cells (4 cols × 3 rows) with the per-month total
class HeatmapCard extends StatefulWidget {
  const HeatmapCard({
    required this.period,
    required this.range,
    required this.sessions,
    this.onDrillDown,
    this.onDaySessionTap,
    super.key,
  });

  final StatsPeriod period;
  final StatsRange range;
  final List<SavedSession> sessions;

  /// Called when the user taps a cell in week / month / year mode to
  /// drill down into a smaller period. Day mode never invokes this
  /// (see [onDaySessionTap]). The callback receives the target period
  /// and an anchor moment inside that period.
  final void Function(StatsPeriod period, DateTime anchor)? onDrillDown;

  /// Day-mode tap target: tapping a per-session tile in day view fires
  /// this with the tapped session. The screen-level handler scrolls
  /// the corresponding session tile into view and expands it.
  final void Function(SavedSession session)? onDaySessionTap;

  @override
  State<HeatmapCard> createState() => _HeatmapCardState();
}

class _HeatmapCardState extends State<HeatmapCard> {

  Color _cellColor(ThemeData theme, int count, int maxCount) {
    if (count == 0 || maxCount == 0) {
      return theme.colorScheme.surfaceContainerHighest;
    }
    final ratio = (count / maxCount).clamp(0.0, 1.0);
    // Bottom rung is a faint tint of primary so empty days still read
    // as "the same scale", just very light.
    return Color.lerp(
      theme.colorScheme.primary.withValues(alpha: 0.25),
      theme.colorScheme.primary,
      ratio,
    )!;
  }

  /// Drill-down target for a tap on a week / month / year cell. Week
  /// cells drop to day, month cells drop to week, year cells drop to
  /// month. Day mode never reaches here — its cells fire
  /// `widget.onDaySessionTap` instead, which the screen turns into a
  /// scroll + expand of the matching session tile.
  void _drillDown(DateTime anchor) {
    final cb = widget.onDrillDown;
    if (cb == null) return;
    switch (widget.period) {
      case StatsPeriod.week:
        cb(StatsPeriod.day, anchor);
      case StatsPeriod.month:
        cb(StatsPeriod.week, anchor);
      case StatsPeriod.year:
        cb(StatsPeriod.month, anchor);
      case StatsPeriod.day:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);

    final byDay = <DateTime, int>{};
    for (final s in widget.sessions) {
      final d = s.session.startedAt;
      final key = DateTime(d.year, d.month, d.day);
      byDay[key] = (byDay[key] ?? 0) + 1;
    }
    final maxCount = byDay.values.fold<int>(0, max);

    final body = switch (widget.period) {
      StatsPeriod.day => _buildDay(theme),
      StatsPeriod.week =>
        _buildWeekOrMonth(theme, byDay, maxCount, isWeek: true),
      StatsPeriod.month =>
        _buildWeekOrMonth(theme, byDay, maxCount, isWeek: false),
      StatsPeriod.year => _buildYear(theme, byDay, maxCount),
    };

    return ChartCard(
      title: '${l.statisticsChartHeatmap}: '
          '${l.statisticsSessionPlural(widget.sessions.length)}',
      child: body,
    );
  }

  /// Both `week` and `month` use a calendar grid (7 cols × N rows). The
  /// only difference is row count, so the same builder handles both.
  Widget _buildWeekOrMonth(
    ThemeData theme,
    Map<DateTime, int> byDay,
    int maxCount, {
    required bool isWeek,
  }) {
    final locale = Localizations.localeOf(context).toString();
    final weekFmt = DateFormat.E(locale);

    final start = isWeek
        ? widget.range.start
        : StatsPeriodMath.startOfWeek(widget.range.start);
    // For month: extend to the end of the week containing range.end.
    final end = isWeek
        ? widget.range.end
        : (widget.range.end.weekday == 1
            ? widget.range.end
            : widget.range.end.add(
                Duration(days: 8 - widget.range.end.weekday),
              ));
    final totalDays = end.difference(start).inDays;
    final rows = totalDays ~/ 7;

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 4.0;
        final cellSize = (constraints.maxWidth - 6 * gap) / 7;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekday header.
            Row(
              children: [
                for (var i = 0; i < 7; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  SizedBox(
                    width: cellSize,
                    child: Center(
                      child: Text(
                        weekFmt.format(start.add(Duration(days: i))),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: gap),
            for (var r = 0; r < rows; r++) ...[
              if (r > 0) const SizedBox(height: gap),
              Row(
                children: [
                  for (var c = 0; c < 7; c++) ...[
                    if (c > 0) const SizedBox(width: gap),
                    _buildCell(
                      theme,
                      byDay,
                      maxCount,
                      start.add(Duration(days: r * 7 + c)),
                      cellSize,
                      isWeek: isWeek,
                    ),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCell(
    ThemeData theme,
    Map<DateTime, int> byDay,
    int maxCount,
    DateTime day,
    double size, {
    required bool isWeek,
  }) {
    final inRange =
        !day.isBefore(widget.range.start) && day.isBefore(widget.range.end);
    if (!inRange) {
      // Out-of-range cell (e.g. trailing days when the month grid
      // extends into the next week) — invisible placeholder so column
      // widths stay aligned.
      return SizedBox(width: size, height: size);
    }
    final count = byDay[day] ?? 0;
    // Future days: render a dash instead of "0" so it's obvious those
    // buckets aren't a flatlining streak — they just haven't happened
    // yet. `today` is used as the cutoff (so today itself is "now",
    // not future).
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isFuture = day.isAfter(today);
    final countLabel = isFuture ? '—' : '$count';
    // High-contrast text on "hot" cells, muted otherwise. Threshold of
    // 60% mirrors the year-month cells. Future-dash cells get an even
    // more muted grey so they read as inactive.
    final hot = maxCount > 0 && count / maxCount > 0.6;
    final fg = isFuture
        ? theme.colorScheme.outline
        : hot
            ? theme.colorScheme.onPrimary
            : (count > 0
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant);
    // Week: only the count (the weekday header above already labels the
    // column). Month: tiny day number above the count so the date is
    // findable at a glance.
    final content = isWeek
        ? Text(
            countLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: theme.textTheme.bodySmall?.copyWith(color: fg),
              ),
              Text(
                countLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          );
    return GestureDetector(
      onTap: () => _drillDown(day),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _cellColor(theme, count, maxCount),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }

  /// Day mode: a flexible grid of session tiles (oldest-first). Each
  /// tile is the same fixed size, colour-tinted by the session's overall
  /// accuracy with the same thresholds the session-list bubble uses
  /// (≥80% primary, <50% error, otherwise tertiary). Tap a tile to see
  /// the session time + score in the subtitle.
  Widget _buildDay(ThemeData theme) {
    final ordered = _sessionsOldestFirst();
    if (ordered.isEmpty) {
      return SizedBox(
        height: 64,
        child: Center(
          child: Text(
            AppLocalizations.of(context).statisticsEmptyTitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mirror the week / month calendar grid so day-mode tiles render
        // at the same fixed size regardless of how many sessions the
        // user has played — 7 columns, 4 px gap, cellSize derived from
        // the available width identically to `_buildWeekOrMonth`.
        const gap = 4.0;
        const cols = 7;
        final cellSize =
            (constraints.maxWidth - (cols - 1) * gap) / cols;
        final rows = (ordered.length / cols).ceil();
        return Column(
          children: [
            for (var r = 0; r < rows; r++) ...[
              if (r > 0) const SizedBox(height: gap),
              Row(
                children: [
                  for (var c = 0; c < cols; c++) ...[
                    if (c > 0) const SizedBox(width: gap),
                    if (r * cols + c < ordered.length)
                      _buildDayCell(
                        theme,
                        ordered[r * cols + c],
                        cellSize,
                      )
                    else
                      // Padding placeholder so the trailing row stays
                      // aligned when ordered.length is not a multiple
                      // of `cols`.
                      SizedBox(width: cellSize, height: cellSize),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDayCell(
    ThemeData theme,
    SavedSession session,
    double size,
  ) {
    final acc = overallAccuracy(session.scores);
    final accColor = accuracyTierColor(theme, acc);
    final accPercent = (acc * 100).round();
    return GestureDetector(
      onTap: () => widget.onDaySessionTap?.call(session),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: accColor.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              nLevelLabel(session.scores.length, session.session.n),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: accColor,
              ),
            ),
            Text(
              '$accPercent%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: accColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sort sessions oldest-first for chronological tile order. The
  /// repository delivers newest-first, so a one-pass copy + sort is
  /// enough — typically dozens of items max per day.
  List<SavedSession> _sessionsOldestFirst() {
    return List<SavedSession>.from(widget.sessions)
      ..sort((a, b) => a.session.startedAt.compareTo(b.session.startedAt));
  }

  /// Year heatmap collapsed to 12 month cells (4 cols × 3 rows). Each
  /// cell shows the abbreviated month name plus the per-month session
  /// total — much more readable than a tiny GitHub-style daily grid on
  /// a phone screen.
  Widget _buildYear(
    ThemeData theme,
    Map<DateTime, int> byDay,
    int maxCount,
  ) {
    final locale = Localizations.localeOf(context).toString();
    final monthFmt = DateFormat.MMM(locale);

    // Per-month totals + per-month max (we colour by month total, so the
    // legend uses that scale, not the per-day max).
    final perMonth = List<int>.filled(12, 0);
    for (final entry in byDay.entries) {
      if (entry.key.year != widget.range.start.year) continue;
      perMonth[entry.key.month - 1] += entry.value;
    }
    final monthMax = perMonth.fold<int>(0, max);

    return LayoutBuilder(
      builder: (context, constraints) {
        const cols = 4;
        const rows = 3;
        const gap = 8.0;
        final cellWidth = (constraints.maxWidth - gap * (cols - 1)) / cols;
        // Slightly squat to fit two centred lines without feeling huge.
        final cellHeight = cellWidth * 0.7;

        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month);

        Widget monthCell(int monthIndex) {
          final monthDate = DateTime(widget.range.start.year, monthIndex + 1);
          final count = perMonth[monthIndex];
          // Months whose 1st falls strictly after the current month are
          // "future" — show a dash instead of "0". The current month
          // itself shows the running count.
          final isFuture = monthDate.isAfter(thisMonth);
          final countLabel = isFuture ? '—' : '$count';
          // Reuse the per-day colour scale, but feed it month totals.
          final color = _cellColor(theme, count, monthMax);
          // White-on-primary readability: when the cell is "hot", flip
          // text to onPrimary so the count stays legible. Future-dash
          // cells use a muted grey for an inactive look.
          final hot = monthMax > 0 && count / monthMax > 0.6;
          final textColor = isFuture
              ? theme.colorScheme.outline
              : (hot
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface);

          return GestureDetector(
            onTap: () => _drillDown(monthDate),
            child: Container(
              width: cellWidth,
              height: cellHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    monthFmt.format(monthDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: textColor,
                    ),
                  ),
                  Text(
                    countLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            for (var r = 0; r < rows; r++) ...[
              if (r > 0) const SizedBox(height: gap),
              Row(
                children: [
                  for (var c = 0; c < cols; c++) ...[
                    if (c > 0) const SizedBox(width: gap),
                    monthCell(r * cols + c),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
