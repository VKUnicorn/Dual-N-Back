import 'package:dual_n_back/features/settings/application/settings_notifier.dart';
import 'package:dual_n_back/features/statistics/data/database.dart';
import 'package:dual_n_back/features/statistics/data/statistics_repository.dart';
import 'package:dual_n_back/features/statistics/domain/saved_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Owns the singleton [AppDatabase]. Tests override this with an
/// in-memory [AppDatabase] backed by `NativeDatabase.memory()`.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return StatisticsRepository(ref.watch(appDatabaseProvider));
});

/// Reactive history — recomputes whenever the underlying tables change
/// (e.g. when `GameNotifier` saves a freshly finished session).
final sessionsHistoryProvider = StreamProvider<List<SavedSession>>((ref) {
  return ref.watch(statisticsRepositoryProvider).watchAll();
});

/// Number of sessions completed since local midnight today. Drives the
/// daily-goal counter on the home screen. Recomputes whenever the
/// underlying history stream emits.
final sessionsTodayCountProvider = Provider<int>((ref) {
  final history = ref.watch(sessionsHistoryProvider);
  return history.maybeWhen(
    data: (sessions) {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      return sessions
          .where((s) => !s.session.startedAt.isBefore(startOfDay))
          .length;
    },
    orElse: () => 0,
  );
});

/// Consecutive days (counting back from today) the configured daily goal
/// was reached. If today's goal isn't met yet the streak is computed from
/// yesterday — an in-progress day shouldn't visually break the streak.
///
/// Rest days (weekdays the user marked in settings) are fully transparent:
/// they neither count toward nor break the streak. The walk-back loop's
/// termination depends on at least one weekday being non-rest, which is
/// enforced by `SettingsModel.maxRestDays` in the notifier and the UI.
final currentStreakProvider = Provider<int>((ref) {
  final goal = ref.watch(
    settingsProvider.select((s) => s.dailyGoalSessions),
  );
  final restDays = ref.watch(
    settingsProvider.select((s) => s.restDays),
  );
  final history = ref.watch(sessionsHistoryProvider);
  return history.maybeWhen(
    data: (sessions) {
      final perDay = <DateTime, int>{};
      for (final entry in sessions) {
        final d = entry.session.startedAt;
        final key = DateTime(d.year, d.month, d.day);
        perDay[key] = (perDay[key] ?? 0) + 1;
      }
      final now = DateTime.now();
      var cursor = DateTime(now.year, now.month, now.day);
      // Today is a rest day OR an in-progress non-goal day → step back so
      // we don't conflate "rest" / "still playing" with "missed".
      if (restDays.contains(cursor.weekday)) {
        cursor = cursor.subtract(const Duration(days: 1));
      } else if ((perDay[cursor] ?? 0) < goal) {
        cursor = cursor.subtract(const Duration(days: 1));
      }
      var streak = 0;
      while (true) {
        if (restDays.contains(cursor.weekday)) {
          // Transparent: skip without incrementing or breaking.
          cursor = cursor.subtract(const Duration(days: 1));
          continue;
        }
        if ((perDay[cursor] ?? 0) >= goal) {
          streak += 1;
          cursor = cursor.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
      return streak;
    },
    orElse: () => 0,
  );
});
