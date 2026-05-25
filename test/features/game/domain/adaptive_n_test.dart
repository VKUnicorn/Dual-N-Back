import 'package:dual_n_back/features/game/domain/adaptive_n.dart';
import 'package:dual_n_back/features/game/domain/response_evaluator.dart';
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:flutter_test/flutter_test.dart';

SessionScore _scoreWithMinAccuracy(double accuracy) {
  // Build one channel with the given accuracy under the current
  // formula: hits / (hits + misses + falseAlarms). Using 100 engaged
  // decisions makes the math exact for thresholds like 0.5 / 0.8.
  // correctRejections is irrelevant here and left at 0.
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
        score: _scoreWithMinAccuracy(0.85),
      );
      expect(result.n, 3);
      expect(result.adjustment, NAdjustment.advance);
    });

    test('regresses when accuracy < 50%', () {
      final result = adaptive.next(
        currentN: 3,
        score: _scoreWithMinAccuracy(0.4),
      );
      expect(result.n, 2);
      expect(result.adjustment, NAdjustment.regress);
    });

    test('holds for accuracies in the middle range', () {
      final result = adaptive.next(
        currentN: 3,
        score: _scoreWithMinAccuracy(0.65),
      );
      expect(result.n, 3);
      expect(result.adjustment, NAdjustment.hold);
    });

    test('exactly at advance threshold advances', () {
      final result = adaptive.next(
        currentN: 2,
        score: _scoreWithMinAccuracy(0.80),
      );
      expect(result.adjustment, NAdjustment.advance);
    });

    test('exactly at regress threshold holds (must be strictly below)', () {
      final result = adaptive.next(
        currentN: 3,
        score: _scoreWithMinAccuracy(0.50),
      );
      expect(result.adjustment, NAdjustment.hold);
    });

    test('does not advance past maxN', () {
      const adaptive = AdaptiveN(maxN: 5);
      final result = adaptive.next(
        currentN: 5,
        score: _scoreWithMinAccuracy(0.95),
      );
      expect(result.n, 5);
      expect(result.adjustment, NAdjustment.hold);
    });

    test('does not regress below minN', () {
      const adaptive = AdaptiveN(minN: 2);
      final result = adaptive.next(
        currentN: 2,
        score: _scoreWithMinAccuracy(0.10),
      );
      expect(result.n, 2);
      expect(result.adjustment, NAdjustment.hold);
    });
  });
}
