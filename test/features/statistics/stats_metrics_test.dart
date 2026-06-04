import 'package:dual_n_back/features/statistics/application/stats_metrics.dart';
import 'package:dual_n_back/features/statistics/domain/saved_session.dart';
import 'package:dual_n_back/features/statistics/domain/stats_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('summarize daily-goal denominator', () {
    // A full past year so the "future days" clamp never trims the window
    // (2024 is a leap year → 366 calendar days).
    final yearRange = StatsRange(
      start: DateTime(2024),
      end: DateTime(2025),
    );
    const noSessions = <SavedSession>[];

    test('counts every calendar day when no first-active clamp is given', () {
      final summary = summarize(yearRange, noSessions, 1);
      expect(summary.totalDays, 366);
    });

    test('clamps the window start to the first-active day', () {
      // First session on 2024-12-23 → only 23..31 Dec should count (9 days).
      final summary = summarize(
        yearRange,
        noSessions,
        1,
        firstActiveDay: DateTime(2024, 12, 23),
      );
      expect(summary.totalDays, 9);
    });

    test('first-active day before the range start does not extend it', () {
      final summary = summarize(
        yearRange,
        noSessions,
        1,
        firstActiveDay: DateTime(2023, 6, 1),
      );
      expect(summary.totalDays, 366);
    });
  });
}
