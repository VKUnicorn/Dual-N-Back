import 'package:dual_n_back/features/game/domain/adaptive_n.dart';
import 'package:dual_n_back/features/game/domain/response_evaluator.dart';
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:flutter_test/flutter_test.dart';

SessionScore _scoreWithAccuracy(double accuracy) {
  // Build one channel with the given accuracy under the current
  // formula: hits / (hits + misses + falseAlarms). Using 100 engaged
  // decisions makes the math exact for thresholds like 0.5 / 0.8.
  // correctRejections is irrelevant here and left at 0.
  //
  // With a single channel, overallAccuracy == accuracy, so this
  // helper also pins the overall accuracy the adaptive rule reads.
  final hits = (accuracy * 100).round();
  final wrong = 100 - hits;
  final misses = wrong ~/ 2;
  final falseAlarms = wrong - misses;
  return SessionScore({
    ChannelType.position: ChannelScore(
      hits: hits,
      misses: misses,
      falseAlarms: falseAlarms,
      correctRejections: 0,
    ),
  });
}

void main() {
  group('AdaptiveN', () {
    // Pin thresholds for the algorithm-level tests so they stay
    // meaningful regardless of the production defaults in
    // [NBackDefaults]. The Jaeggi 0.8/0.5 pair is the canonical
    // reference and keeps the hand-picked accuracy fixtures below
    // (0.4 / 0.5 / 0.65 / 0.80 / 0.85) on the same side of the rails
    // they were originally written against.
    const adaptive = AdaptiveN(
      advanceThreshold: 0.8,
      regressThreshold: 0.5,
    );

    test('advances when accuracy >= 80%', () {
      final result = adaptive.next(
        currentN: 2,
        score: _scoreWithAccuracy(0.85),
      );
      expect(result.n, 3);
      expect(result.adjustment, NAdjustment.advance);
    });

    test('regresses when accuracy <= 50%', () {
      final result = adaptive.next(
        currentN: 3,
        score: _scoreWithAccuracy(0.4),
      );
      expect(result.n, 2);
      expect(result.adjustment, NAdjustment.regress);
    });

    test('holds for accuracies in the middle range', () {
      final result = adaptive.next(
        currentN: 3,
        score: _scoreWithAccuracy(0.65),
      );
      expect(result.n, 3);
      expect(result.adjustment, NAdjustment.hold);
    });

    test('exactly at advance threshold advances', () {
      final result = adaptive.next(
        currentN: 2,
        score: _scoreWithAccuracy(0.80),
      );
      expect(result.adjustment, NAdjustment.advance);
    });

    test('exactly at regress threshold regresses (inclusive lower rail)', () {
      final result = adaptive.next(
        currentN: 3,
        score: _scoreWithAccuracy(0.50),
      );
      expect(result.n, 2);
      expect(result.adjustment, NAdjustment.regress);
    });

    test('does not advance past maxN', () {
      const adaptive = AdaptiveN(maxN: 5);
      final result = adaptive.next(
        currentN: 5,
        score: _scoreWithAccuracy(0.95),
      );
      expect(result.n, 5);
      expect(result.adjustment, NAdjustment.hold);
    });

    test('does not regress below minN', () {
      const adaptive = AdaptiveN(minN: 2);
      final result = adaptive.next(
        currentN: 2,
        score: _scoreWithAccuracy(0.10),
      );
      expect(result.n, 2);
      expect(result.adjustment, NAdjustment.hold);
    });

    test('user-reported: 65% overall holds at 60% regress rail', () {
      // Reproduces a bug report where a dual session showed 65% overall
      // accuracy on the result screen but the adaptive rule still
      // regressed. Under the legacy min-accuracy logic this happened
      // whenever one channel dragged the minimum below the rail —
      // pooled accuracy is what the user sees on screen, so it must be
      // what the adaptive rule reads.
      const adaptive = AdaptiveN(regressThreshold: 0.6);
      // position: 18 hits / 2 misses, 0 fa → 18/20 = 90%
      // audio:    8 hits / 8 misses, 4 fa → 8/20 = 40%
      // overall = 26 / 40 = 65% → above 60% rail → HOLD
      const score = SessionScore({
        ChannelType.position: ChannelScore(
          hits: 18,
          misses: 2,
          falseAlarms: 0,
          correctRejections: 10,
        ),
        ChannelType.audio: ChannelScore(
          hits: 8,
          misses: 8,
          falseAlarms: 4,
          correctRejections: 10,
        ),
      });
      expect(score.overallAccuracy, closeTo(0.65, 0.001));
      expect(score.minAccuracy, closeTo(0.40, 0.001));

      final result = adaptive.next(currentN: 4, score: score);
      expect(result.n, 4, reason: 'must hold — overall 65% > 60% rail');
      expect(result.adjustment, NAdjustment.hold);
    });

    test('uses overall (pooled) accuracy, not worst per-channel', () {
      // Regression test for the user-reported issue: a dual session with
      // position 90% / audio 68% pools to ~79% — above the 70% regress
      // rail and below the 90% advance rail → must hold. The legacy
      // min-accuracy rule would have regressed on the 68% channel.
      const adaptive = AdaptiveN();
      // 9 hits / 1 miss on position = 90% (10 engaged).
      // 6 hits / 3 misses + 1 false alarm on audio ≈ 60% (10 engaged).
      // Overall = 15 / 20 = 75% → strictly between 70 and 90 → hold.
      const score = SessionScore({
        ChannelType.position: ChannelScore(
          hits: 9,
          misses: 1,
          falseAlarms: 0,
          correctRejections: 10,
        ),
        ChannelType.audio: ChannelScore(
          hits: 6,
          misses: 3,
          falseAlarms: 1,
          correctRejections: 10,
        ),
      });
      // Sanity: the worst per-channel accuracy is below the regress
      // rail, so this would have regressed under the legacy rule.
      expect(score.minAccuracy, lessThanOrEqualTo(0.7));
      expect(score.overallAccuracy, closeTo(0.75, 0.001));

      final result = adaptive.next(currentN: 3, score: score);
      expect(result.n, 3);
      expect(result.adjustment, NAdjustment.hold);
    });
  });
}
