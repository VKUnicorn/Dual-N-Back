import 'package:meta/meta.dart';

/// Time-window mode for the statistics screen.
enum StatsPeriod { day, week, month, year }

/// Half-open `[start, end)` window covering one period.
///
/// All boundaries are at local midnight (00:00:00.000) and `end` is the
/// first moment of the *next* period — making same-day comparisons
/// against `session.startedAt` straightforward via
/// `!s.isBefore(start) && s.isBefore(end)`.
@immutable
class StatsRange {
  const StatsRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  /// Number of "buckets" the chart x-axis should display:
  ///   day   → 1 (the whole day collapses to a single point)
  ///   week  → 7 days
  ///   month → days-in-month (28..31)
  ///   year  → 12 months
  int bucketCount(StatsPeriod period) {
    switch (period) {
      case StatsPeriod.day:
        return 1;
      case StatsPeriod.week:
        return 7;
      case StatsPeriod.month:
        return DateTime(start.year, start.month + 1, 0).day;
      case StatsPeriod.year:
        return 12;
    }
  }

  /// Maps a session's `startedAt` to its bucket index `[0, bucketCount)`,
  /// or `-1` if it falls outside this range.
  int bucketIndexFor(StatsPeriod period, DateTime ts) {
    if (ts.isBefore(start) || !ts.isBefore(end)) return -1;
    switch (period) {
      case StatsPeriod.day:
        return 0;
      case StatsPeriod.week:
      case StatsPeriod.month:
        // Days since `start`, calendar-aware so DST doesn't shift buckets.
        final d0 = DateTime(start.year, start.month, start.day);
        final d1 = DateTime(ts.year, ts.month, ts.day);
        return d1.difference(d0).inDays;
      case StatsPeriod.year:
        return ts.month - 1;
    }
  }
}

/// Boundary helpers. All operations work in local time — the user's
/// week starts on Monday and a "month"/"year" is the calendar one.
class StatsPeriodMath {
  /// Local midnight of the calendar day containing [d].
  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Start of the ISO week (Monday) at midnight that contains [d].
  static DateTime startOfWeek(DateTime d) {
    final base = DateTime(d.year, d.month, d.day);
    // DateTime.weekday: Mon=1..Sun=7
    return base.subtract(Duration(days: base.weekday - 1));
  }

  static DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month);

  static DateTime startOfYear(DateTime d) => DateTime(d.year);

  /// Range that contains [anchor] for the given [period].
  static StatsRange rangeFor(StatsPeriod period, DateTime anchor) {
    switch (period) {
      case StatsPeriod.day:
        final s = startOfDay(anchor);
        return StatsRange(start: s, end: s.add(const Duration(days: 1)));
      case StatsPeriod.week:
        final s = startOfWeek(anchor);
        return StatsRange(start: s, end: s.add(const Duration(days: 7)));
      case StatsPeriod.month:
        final s = startOfMonth(anchor);
        return StatsRange(start: s, end: DateTime(s.year, s.month + 1));
      case StatsPeriod.year:
        final s = startOfYear(anchor);
        return StatsRange(start: s, end: DateTime(s.year + 1));
    }
  }

  /// Move [anchor] forward/backward by one whole period.
  static DateTime shift(StatsPeriod period, DateTime anchor, int delta) {
    switch (period) {
      case StatsPeriod.day:
        return startOfDay(anchor).add(Duration(days: delta));
      case StatsPeriod.week:
        return startOfWeek(anchor).add(Duration(days: 7 * delta));
      case StatsPeriod.month:
        return DateTime(anchor.year, anchor.month + delta);
      case StatsPeriod.year:
        return DateTime(anchor.year + delta);
    }
  }

  /// Whole periods between [a] and [b] (positive when [b] is later).
  /// "Whole" is defined relative to the period's start boundary, so the
  /// distance between Mon-of-week-A and Wed-of-week-A is 0 weeks.
  static int periodsBetween(StatsPeriod period, DateTime a, DateTime b) {
    switch (period) {
      case StatsPeriod.day:
        return startOfDay(b).difference(startOfDay(a)).inDays;
      case StatsPeriod.week:
        final sa = startOfWeek(a);
        final sb = startOfWeek(b);
        return sb.difference(sa).inDays ~/ 7;
      case StatsPeriod.month:
        return (b.year - a.year) * 12 + (b.month - a.month);
      case StatsPeriod.year:
        return b.year - a.year;
    }
  }
}
