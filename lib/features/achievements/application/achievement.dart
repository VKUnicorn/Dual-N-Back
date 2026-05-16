import 'package:dual_n_back/features/achievements/domain/achievement_group.dart';
import 'package:dual_n_back/features/achievements/domain/achievement_progress.dart';
import 'package:dual_n_back/features/achievements/domain/eval_session.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

typedef AchievementEvaluator = AchievementProgress Function(EvalContext ctx);
typedef AchievementLocalizer = String Function(AppLocalizations l);

/// Catalog entry: a single achievement definition.
///
/// `evaluate` is a pure function — given a snapshot of history + context,
/// it returns the current progress. Achievements are intentionally
/// monotonic (max-ever streak, ever-completed sessions, etc.) so the
/// `earned` flag never flips back to false.
@immutable
class Achievement {
  const Achievement({
    required this.id,
    required this.group,
    required this.icon,
    required this.tracksProgress,
    required this.localizedTitle,
    required this.localizedDescription,
    required this.evaluate,
  });

  final String id;
  final AchievementGroup group;
  final IconData icon;
  final bool tracksProgress;
  final AchievementLocalizer localizedTitle;
  final AchievementLocalizer localizedDescription;
  final AchievementEvaluator evaluate;
}

/// Inputs the evaluator can read.
@immutable
class EvalContext {
  const EvalContext({
    required this.sessions,
    required this.dailyGoal,
    required this.now,
    this.restDays = const <int>{},
  });

  /// All completed sessions, newest first (matches `loadAll()` ordering).
  final List<EvalSession> sessions;

  /// Daily session goal from settings — drives streak rules.
  final int dailyGoal;

  /// Reference "now" for time-based rules (e.g. Veteran). Injected so tests
  /// can use a fixed clock.
  final DateTime now;

  /// Weekdays the user marked as rest (`DateTime.weekday`, 1=Mon..7=Sun).
  /// Streak rules treat these as transparent — they neither extend nor
  /// break a run. Defaults to empty so older tests keep their semantics.
  final Set<int> restDays;
}

/// Runs every achievement in `catalog` against `ctx` and returns a map of
/// `id → progress`. Pure — no side effects, no dependency on Flutter.
Map<String, AchievementProgress> evaluateAchievements(
  List<Achievement> catalog,
  EvalContext ctx,
) =>
    {for (final a in catalog) a.id: a.evaluate(ctx)};
