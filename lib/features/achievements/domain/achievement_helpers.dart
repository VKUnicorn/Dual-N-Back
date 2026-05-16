import 'package:dual_n_back/features/achievements/domain/eval_session.dart';

/// Pure-Dart helpers used by individual achievement rules. Kept in the
/// domain layer (no Flutter imports) so they can be unit-tested in
/// isolation and reused across rules.
abstract final class AchievementHelpers {
  /// Length (in days) of the longest run of consecutive calendar days
  /// where the daily session count was >= `dailyGoal`. Returns 0 if no
  /// day ever met the goal.
  ///
  /// `restDays` (`DateTime.weekday` values, 1=Mon..7=Sun) are treated as
  /// transparent: any number of rest-day weekdays between two goal-met
  /// days does not break the run. With an empty `restDays` set the
  /// behaviour matches the original "calendar-adjacent" definition.
  static int bestStreakEver(
    List<EvalSession> sessions,
    int dailyGoal, [
    Set<int> restDays = const <int>{},
  ]) {
    if (sessions.isEmpty || dailyGoal <= 0) return 0;
    final perDay = _sessionsPerDay(sessions);
    if (perDay.isEmpty) return 0;
    final goalDays = perDay.entries
        .where((e) => e.value >= dailyGoal)
        .map((e) => e.key)
        .toList()
      ..sort();
    if (goalDays.isEmpty) return 0;
    var best = 1;
    var run = 1;
    for (var i = 1; i < goalDays.length; i++) {
      if (_onlyRestDaysBetween(goalDays[i - 1], goalDays[i], restDays)) {
        run += 1;
        if (run > best) best = run;
      } else {
        run = 1;
      }
    }
    return best;
  }

  /// True iff every calendar day strictly between `a` and `b` is a rest
  /// day. Includes the `b == a + 1 day` case (loop body executes 0 times)
  /// — so with empty `restDays` the function reduces to `diff == 1`,
  /// matching the original consecutive-day check.
  static bool _onlyRestDaysBetween(
    DateTime a,
    DateTime b,
    Set<int> restDays,
  ) {
    var cursor = a.add(const Duration(days: 1));
    while (cursor.isBefore(b)) {
      if (!restDays.contains(cursor.weekday)) return false;
      cursor = cursor.add(const Duration(days: 1));
    }
    return true;
  }

  /// Count of distinct calendar days that have at least one session
  /// matching [predicate].
  static int daysWithMatchingSession(
    List<EvalSession> sessions,
    bool Function(EvalSession) predicate,
  ) {
    final days = <DateTime>{};
    for (final s in sessions) {
      if (predicate(s)) {
        final d = s.startedAt;
        days.add(DateTime(d.year, d.month, d.day));
      }
    }
    return days.length;
  }

  /// True if there exists any calendar day where (a) at least one session
  /// has [EvalSession.overallAccuracy] < 0.8 and (b) chronologically after
  /// that session, at least 3 more sessions occur on the same day.
  ///
  /// Implements the "Persistent" rule: 1 failure + 3 follow-ups = 4 total
  /// sessions in the day with the failure not being the last.
  static bool hasComebackDay(List<EvalSession> sessions) {
    final byDay = <DateTime, List<EvalSession>>{};
    for (final s in sessions) {
      final key = DateTime(
        s.startedAt.year,
        s.startedAt.month,
        s.startedAt.day,
      );
      byDay.putIfAbsent(key, () => []).add(s);
    }
    for (final list in byDay.values) {
      if (list.length < 4) continue;
      list.sort((a, b) => a.startedAt.compareTo(b.startedAt));
      for (var i = 0; i < list.length - 3; i++) {
        if (list[i].overallAccuracy < 0.8) return true;
      }
    }
    return false;
  }

  static Map<DateTime, int> _sessionsPerDay(List<EvalSession> sessions) {
    final result = <DateTime, int>{};
    for (final s in sessions) {
      final key = DateTime(
        s.startedAt.year,
        s.startedAt.month,
        s.startedAt.day,
      );
      result[key] = (result[key] ?? 0) + 1;
    }
    return result;
  }
}
