import 'package:dual_n_back/features/achievements/application/achievement.dart';
import 'package:dual_n_back/features/achievements/application/achievements_catalog.dart';
import 'package:dual_n_back/features/achievements/domain/achievement_helpers.dart';
import 'package:dual_n_back/features/achievements/domain/eval_session.dart';
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<Achievement> catalog;
  final fixedNow = DateTime(2026, 5, 7, 12);

  setUp(() {
    catalog = buildAchievementsCatalog();
  });

  EvalContext ctx(
    List<EvalSession> sessions, {
    int dailyGoal = 20,
    DateTime? now,
  }) =>
      EvalContext(
        sessions: sessions,
        dailyGoal: dailyGoal,
        now: now ?? fixedNow,
      );

  bool earned(Map<String, dynamic> result, String id) =>
      (result[id] as dynamic).earned == true;

  group('Helpers', () {
    test('bestStreakEver returns 0 for empty history', () {
      expect(AchievementHelpers.bestStreakEver(const [], 1), 0);
    });

    test('bestStreakEver finds longest run when goal met daily', () {
      // 3 days in a row each meeting goal=2, then a gap, then 2 more days.
      final sessions = [
        for (final day in [1, 2, 3, 5, 6])
          for (var i = 0; i < 2; i++)
            _session(startedAt: DateTime(2026, 5, day, 10 + i)),
      ];
      expect(AchievementHelpers.bestStreakEver(sessions, 2), 3);
    });

    test('bestStreakEver ignores days under the goal', () {
      final sessions = [
        _session(startedAt: DateTime(2026, 5, 1, 10)),
        _session(startedAt: DateTime(2026, 5, 1, 11)),
        // Day 2 only has 1 session — under goal=2.
        _session(startedAt: DateTime(2026, 5, 2, 10)),
        _session(startedAt: DateTime(2026, 5, 3, 10)),
        _session(startedAt: DateTime(2026, 5, 3, 11)),
      ];
      expect(AchievementHelpers.bestStreakEver(sessions, 2), 1);
    });

    test('bestStreakEver bridges a single rest-day gap', () {
      // 2026-05-01 (Fri), 2026-05-02 (Sat), 2026-05-03 (Sun).
      // Goal met on Fri + Sun, Sat skipped — with Sat as rest day the
      // run spans both goal-met days for length 2.
      final sessions = [
        _session(startedAt: DateTime(2026, 5, 1, 10)),
        _session(startedAt: DateTime(2026, 5, 1, 11)),
        _session(startedAt: DateTime(2026, 5, 3, 10)),
        _session(startedAt: DateTime(2026, 5, 3, 11)),
      ];
      expect(
        AchievementHelpers.bestStreakEver(sessions, 2, const {6}),
        2,
      );
    });

    test('bestStreakEver bridges multiple consecutive rest days', () {
      // Fri 2026-05-01, then Sat+Sun rest, then Mon 2026-05-04 goal.
      final sessions = [
        _session(startedAt: DateTime(2026, 5, 1, 10)),
        _session(startedAt: DateTime(2026, 5, 1, 11)),
        _session(startedAt: DateTime(2026, 5, 4, 10)),
        _session(startedAt: DateTime(2026, 5, 4, 11)),
      ];
      expect(
        AchievementHelpers.bestStreakEver(sessions, 2, const {6, 7}),
        2,
      );
    });

    test('bestStreakEver still breaks when a non-rest day is empty', () {
      // Same 1-day gap as the bridging test but with no rest days
      // configured — the empty Saturday breaks the run, so each goal-met
      // day stands alone for run=1.
      final sessions = [
        _session(startedAt: DateTime(2026, 5, 1, 10)),
        _session(startedAt: DateTime(2026, 5, 1, 11)),
        _session(startedAt: DateTime(2026, 5, 3, 10)),
        _session(startedAt: DateTime(2026, 5, 3, 11)),
      ];
      expect(
        AchievementHelpers.bestStreakEver(sessions, 2),
        1,
      );
    });

    test('hasComebackDay finds a failure followed by 3+ same-day sessions',
        () {
      final sessions = [
        _session(
          startedAt: DateTime(2026, 5, 1, 9),
          failed: true,
        ),
        _session(startedAt: DateTime(2026, 5, 1, 10)),
        _session(startedAt: DateTime(2026, 5, 1, 11)),
        _session(startedAt: DateTime(2026, 5, 1, 12)),
      ];
      expect(AchievementHelpers.hasComebackDay(sessions), isTrue);
    });

    test('hasComebackDay false if failure was last session of the day', () {
      final sessions = [
        _session(startedAt: DateTime(2026, 5, 1, 9)),
        _session(startedAt: DateTime(2026, 5, 1, 10)),
        _session(startedAt: DateTime(2026, 5, 1, 11)),
        _session(
          startedAt: DateTime(2026, 5, 1, 12),
          failed: true,
        ),
      ];
      expect(AchievementHelpers.hasComebackDay(sessions), isFalse);
    });

    test('daysWithMatchingSession counts distinct calendar days', () {
      final sessions = [
        _session(startedAt: DateTime(2026, 5, 1, 7)),
        _session(startedAt: DateTime(2026, 5, 1, 7, 30)),
        _session(startedAt: DateTime(2026, 5, 2, 7)),
        _session(startedAt: DateTime(2026, 5, 3, 9)), // not before 8am
      ];
      final days = AchievementHelpers.daysWithMatchingSession(
        sessions,
        (s) => s.startedAt.hour < 8,
      );
      expect(days, 2);
    });
  });

  group('Empty history', () {
    test('every achievement is unearned (except those with default 0 target)',
        () {
      final result = evaluateAchievements(catalog, ctx(const []));
      // Spot-check a few that must be false at zero history.
      expect(earned(result, 'centurion'), isFalse);
      expect(earned(result, 'awakened_neuron'), isFalse);
      expect(earned(result, 'sharp_brain'), isFalse);
      expect(earned(result, 'sniper'), isFalse);
      expect(earned(result, 'persistent'), isFalse);
      expect(earned(result, 'audiophile'), isFalse);
    });
  });

  group('Milestones', () {
    test('awakened_neuron earned with first session', () {
      final result = evaluateAchievements(
        catalog,
        ctx([_session(startedAt: DateTime(2026, 5, 7, 10))]),
      );
      expect(earned(result, 'awakened_neuron'), isTrue);
      expect(earned(result, 'centurion'), isFalse);
    });

    test('practitioner tracks total trials', () {
      final result = evaluateAchievements(
        catalog,
        ctx([
          _session(
            startedAt: DateTime(2026, 5, 7, 10),
            totalTrials: 5000,
          ),
        ]),
      );
      expect(earned(result, 'practitioner'), isTrue);
      expect(earned(result, 'trained'), isFalse);
    });

    test('veteran needs 365+ days since first session', () {
      final result = evaluateAchievements(
        catalog,
        ctx(
          [_session(startedAt: DateTime(2025, 5, 6, 10))],
          now: DateTime(2026, 5, 7, 12),
        ),
      );
      expect(earned(result, 'veteran'), isTrue);
    });
  });

  group('Performance ladder', () {
    test('high N session unlocks all lower-N performance achievements', () {
      // N=10 with 90% accuracy implies sharp_brain, muscular_brain, etc.
      final result = evaluateAchievements(
        catalog,
        ctx([_perfectSession(n: 10, accuracy: 0.9)]),
      );
      expect(earned(result, 'sharp_brain'), isTrue);
      expect(earned(result, 'muscular_brain'), isTrue);
      expect(earned(result, 'olympic_brain'), isTrue);
      expect(earned(result, 'genius_brain'), isTrue);
      expect(earned(result, 'cognitive_elite'), isTrue);
      expect(earned(result, 'cosmic_mind'), isTrue);
      expect(earned(result, 'mythic_mind'), isTrue);
      expect(earned(result, 'superhuman'), isTrue);
      expect(earned(result, 'sniper'), isTrue);
    });

    test('sniper requires N>=4', () {
      final result = evaluateAchievements(
        catalog,
        ctx([_perfectSession(n: 3, accuracy: 1)]),
      );
      expect(earned(result, 'sniper'), isFalse);
    });

    test('untouchable requires zero misses and zero false alarms', () {
      final perfect = _session(
        n: 5,
        startedAt: DateTime(2026, 5, 7, 10),
        perChannel: {
          ChannelType.position: const EvalChannelScore(
            hits: 6,
            misses: 0,
            falseAlarms: 0,
            correctRejections: 14,
            accuracy: 1,
            dPrime: 4,
          ),
        },
      );
      final imperfect = _session(
        n: 5,
        startedAt: DateTime(2026, 5, 7, 10),
        perChannel: {
          ChannelType.position: const EvalChannelScore(
            hits: 5,
            misses: 1,
            falseAlarms: 0,
            correctRejections: 14,
            accuracy: 0.83,
            dPrime: 3.5,
          ),
        },
      );
      expect(
        earned(evaluateAchievements(catalog, ctx([perfect])), 'untouchable'),
        isTrue,
      );
      expect(
        earned(
          evaluateAchievements(catalog, ctx([imperfect])),
          'untouchable',
        ),
        isFalse,
      );
    });

    test('dprime_master requires max(channels.dPrime) > 3.0', () {
      final s = _session(
        n: 4,
        startedAt: DateTime(2026, 5, 7, 10),
        perChannel: {
          ChannelType.position: const EvalChannelScore(
            hits: 5,
            misses: 1,
            falseAlarms: 0,
            correctRejections: 14,
            accuracy: 0.83,
            dPrime: 3.1,
          ),
          ChannelType.audio: const EvalChannelScore(
            hits: 4,
            misses: 2,
            falseAlarms: 1,
            correctRejections: 13,
            accuracy: 0.6,
            dPrime: 2.5,
          ),
        },
      );
      expect(
        earned(evaluateAchievements(catalog, ctx([s])), 'dprime_master'),
        isTrue,
      );
    });
  });

  group('Consistency', () {
    test('early_bird counts distinct days with session before 8am', () {
      final sessions = [
        for (final day in [1, 2, 3, 4, 5])
          _session(startedAt: DateTime(2026, 5, day, 7)),
      ];
      final result = evaluateAchievements(catalog, ctx(sessions));
      expect(earned(result, 'early_bird'), isTrue);
    });

    test('night_owl needs 5 distinct days with session at >=22:00', () {
      final sessions = [
        for (final day in [1, 2, 3, 4])
          _session(startedAt: DateTime(2026, 5, day, 22, 30)),
      ];
      // 4 distinct days < 5 → not earned.
      final result = evaluateAchievements(catalog, ctx(sessions));
      expect(earned(result, 'night_owl'), isFalse);
    });
  });

  group('Resilience', () {
    test('steady_hands needs zero false alarms at N>=4 with >=80% overall',
        () {
      final s = _session(
        n: 4,
        startedAt: DateTime(2026, 5, 7, 10),
        perChannel: {
          ChannelType.position: const EvalChannelScore(
            hits: 5,
            misses: 1,
            falseAlarms: 0,
            correctRejections: 14,
            accuracy: 0.83,
            dPrime: 3.5,
          ),
        },
      );
      expect(
        earned(evaluateAchievements(catalog, ctx([s])), 'steady_hands'),
        isTrue,
      );
    });
  });

  group('Exploration', () {
    test('audiophile requires position+audio with audio>80, position<70', () {
      final s = _session(
        n: 4,
        startedAt: DateTime(2026, 5, 7, 10),
        activeChannels: {ChannelType.position, ChannelType.audio},
        perChannel: {
          ChannelType.position: const EvalChannelScore(
            hits: 3,
            misses: 3,
            falseAlarms: 1,
            correctRejections: 13,
            accuracy: 0.43,
            dPrime: 1,
          ),
          ChannelType.audio: const EvalChannelScore(
            hits: 6,
            misses: 0,
            falseAlarms: 1,
            correctRejections: 13,
            accuracy: 0.86,
            dPrime: 3,
          ),
        },
      );
      expect(
        earned(evaluateAchievements(catalog, ctx([s])), 'audiophile'),
        isTrue,
      );
    });

    test('dual_master requires both >85 with overall>=60%', () {
      final s = _session(
        n: 4,
        startedAt: DateTime(2026, 5, 7, 10),
        activeChannels: {ChannelType.position, ChannelType.audio},
        perChannel: {
          ChannelType.position: const EvalChannelScore(
            hits: 6,
            misses: 0,
            falseAlarms: 0,
            correctRejections: 14,
            accuracy: 1,
            dPrime: 4,
          ),
          ChannelType.audio: const EvalChannelScore(
            hits: 6,
            misses: 0,
            falseAlarms: 0,
            correctRejections: 14,
            accuracy: 1,
            dPrime: 4,
          ),
        },
      );
      expect(
        earned(evaluateAchievements(catalog, ctx([s])), 'dual_master'),
        isTrue,
      );
      expect(
        earned(evaluateAchievements(catalog, ctx([s])), 'dual_elite'),
        isTrue,
      );
    });
  });
}

/// Test session factory with sensible defaults: n=2, single position channel,
/// 20 trials, accuracy ~0.85 (or near 0 if `failed: true`).
EvalSession _session({
  required DateTime startedAt,
  int n = 2,
  int totalTrials = 20,
  bool failed = false,
  Set<ChannelType>? activeChannels,
  Map<ChannelType, EvalChannelScore>? perChannel,
}) {
  final channels = activeChannels ?? const {ChannelType.position};
  final scores = perChannel ??
      {
        for (final c in channels)
          c: failed
              ? const EvalChannelScore(
                  hits: 1,
                  misses: 5,
                  falseAlarms: 4,
                  correctRejections: 10,
                  accuracy: 0.1,
                  dPrime: 0.5,
                )
              : const EvalChannelScore(
                  hits: 5,
                  misses: 1,
                  falseAlarms: 0,
                  correctRejections: 14,
                  accuracy: 0.83,
                  dPrime: 3.5,
                ),
      };
  return EvalSession(
    startedAt: startedAt,
    n: n,
    activeChannels: channels,
    totalTrials: totalTrials,
    perChannel: scores,
  );
}

/// Single-channel session with the requested overall accuracy at the given N.
EvalSession _perfectSession({required int n, required double accuracy}) {
  // Build counts that produce roughly the requested accuracy without
  // false alarms — keeps test math simple.
  final hits = (10 * accuracy).round();
  final misses = 10 - hits;
  return EvalSession(
    startedAt: DateTime(2026, 5, 7, 12),
    n: n,
    activeChannels: const {ChannelType.position},
    totalTrials: 20 + n,
    perChannel: {
      ChannelType.position: EvalChannelScore(
        hits: hits,
        misses: misses,
        falseAlarms: 0,
        correctRejections: 10,
        accuracy: accuracy,
        dPrime: 3.5,
      ),
    },
  );
}
