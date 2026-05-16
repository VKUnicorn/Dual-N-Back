import 'package:dual_n_back/features/achievements/application/achievement.dart';
import 'package:dual_n_back/features/achievements/application/achievements_catalog.dart';
import 'package:dual_n_back/features/achievements/data/eval_session_adapter.dart';
import 'package:dual_n_back/features/achievements/domain/achievement_progress.dart';
import 'package:dual_n_back/features/settings/application/settings_notifier.dart';
import 'package:dual_n_back/features/statistics/application/statistics_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Static catalog of achievements. Built once per process; safe to reuse —
/// each entry is immutable and its evaluator is a pure function.
final achievementsCatalogProvider = Provider<List<Achievement>>((ref) {
  return buildAchievementsCatalog();
});

/// Reactive map of `id → AchievementProgress`. Recomputes on every change
/// to `sessionsHistoryProvider` (a session was saved or cleared) or to
/// `dailyGoalSessions` (streak rules change). Until the history stream
/// emits, returns an empty map (UI shows all unearned with 0 progress).
final achievementsProgressProvider =
    Provider<Map<String, AchievementProgress>>((ref) {
  final history = ref.watch(sessionsHistoryProvider);
  final dailyGoal = ref.watch(
    settingsProvider.select((s) => s.dailyGoalSessions),
  );
  final restDays = ref.watch(
    settingsProvider.select((s) => s.restDays),
  );
  final catalog = ref.watch(achievementsCatalogProvider);
  return history.maybeWhen(
    data: (sessions) {
      final ctx = EvalContext(
        sessions:
            sessions.map(EvalSessionAdapter.fromSaved).toList(growable: false),
        dailyGoal: dailyGoal,
        restDays: restDays,
        now: DateTime.now(),
      );
      return evaluateAchievements(catalog, ctx);
    },
    orElse: () => const {},
  );
});
