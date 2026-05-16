import 'package:dual_n_back/features/game/domain/response_evaluator.dart';
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/game/domain/trial.dart';
import 'package:flutter_test/flutter_test.dart';

Trial _trial(int index, {required bool position}) {
  return Trial(
    index: index,
    frame: const StimulusFrame({ChannelType.position: 0}),
    isMatch: {ChannelType.position: position},
  );
}

void main() {
  group('ChannelScore', () {
    test('accuracy and rates are correct', () {
      const score = ChannelScore(
        hits: 8,
        misses: 2,
        falseAlarms: 3,
        correctRejections: 7,
      );
      expect(score.total, 20);
      expect(score.totalSignals, 10);
      expect(score.totalNoise, 10);
      expect(score.engagedDecisions, 13);
      // accuracy = hits / (hits + misses + falseAlarms) = 8 / 13.
      expect(score.accuracy, closeTo(8 / 13, 1e-9));
      expect(score.hitRate, closeTo(0.8, 1e-9));
      expect(score.falseAlarmRate, closeTo(0.3, 1e-9));
    });

    test('accuracy is 0 when the player never engages', () {
      // No hits, no false alarms, no misses — the player neither pressed
      // nor needed to press. accuracy is 0 (not undefined / 100%).
      const inactive = ChannelScore(
        hits: 0,
        misses: 0,
        falseAlarms: 0,
        correctRejections: 20,
      );
      expect(inactive.accuracy, 0);

      // Pure pass-through: no presses across many match trials —
      // accuracy must be 0, not the 70% bonus from correct rejections.
      const passive = ChannelScore(
        hits: 0,
        misses: 6,
        falseAlarms: 0,
        correctRejections: 14,
      );
      expect(passive.accuracy, 0);
    });

    test('d-prime: higher hit rate, lower false alarm rate -> higher d-prime',
        () {
      const good = ChannelScore(
        hits: 9,
        misses: 1,
        falseAlarms: 1,
        correctRejections: 9,
      );
      const bad = ChannelScore(
        hits: 5,
        misses: 5,
        falseAlarms: 5,
        correctRejections: 5,
      );
      expect(good.dPrime, greaterThan(bad.dPrime));
      expect(bad.dPrime, closeTo(0, 0.2));
    });

    test('d-prime is finite at extremes (log-linear correction)', () {
      const perfect = ChannelScore(
        hits: 10,
        misses: 0,
        falseAlarms: 0,
        correctRejections: 10,
      );
      expect(perfect.dPrime.isFinite, isTrue);
      expect(perfect.dPrime, greaterThan(2));
    });
  });

  group('ResponseEvaluator', () {
    const evaluator = ResponseEvaluator();

    test('warm-up trials are excluded from scoring', () {
      // n = 2, trials 0 and 1 are warm-up.
      final trials = [
        _trial(0, position: false),
        _trial(1, position: false),
        _trial(2, position: true),
        _trial(3, position: false),
      ];
      // User pressed on trial 0 (warm-up) and trial 2.
      final responses = {
        ChannelType.position: {0, 2},
      };
      final result = evaluator.evaluate(
        trials: trials,
        n: 2,
        responses: responses,
      );
      final score = result.perChannel[ChannelType.position]!;
      // Trial 0: warm-up, ignored.
      // Trial 1: warm-up, ignored.
      // Trial 2: match present, pressed -> hit.
      // Trial 3: no match, not pressed -> correct rejection.
      expect(score.hits, 1);
      expect(score.misses, 0);
      expect(score.falseAlarms, 0);
      expect(score.correctRejections, 1);
      expect(score.total, 2);
    });

    test('counts hits, misses, false alarms, correct rejections', () {
      // n = 1; trials 1..4 score.
      final trials = [
        _trial(0, position: false), // warm-up
        _trial(1, position: true), // match
        _trial(2, position: true), // match
        _trial(3, position: false), // no match
        _trial(4, position: false), // no match
      ];
      final responses = {
        ChannelType.position: {1, 3}, // press on 1 and 3
      };
      final result = evaluator.evaluate(
        trials: trials,
        n: 1,
        responses: responses,
      );
      final score = result.perChannel[ChannelType.position]!;
      expect(score.hits, 1); // trial 1
      expect(score.misses, 1); // trial 2
      expect(score.falseAlarms, 1); // trial 3
      expect(score.correctRejections, 1); // trial 4
    });

    test('handles missing response set as no presses', () {
      final trials = [
        _trial(0, position: false),
        _trial(1, position: true),
        _trial(2, position: false),
      ];
      final result = evaluator.evaluate(
        trials: trials,
        n: 1,
        responses: const {},
      );
      final score = result.perChannel[ChannelType.position]!;
      expect(score.hits, 0);
      expect(score.misses, 1);
      expect(score.falseAlarms, 0);
      expect(score.correctRejections, 1);
    });

    test('empty trial list returns empty result', () {
      final result = evaluator.evaluate(
        trials: const [],
        n: 1,
        responses: const {},
      );
      expect(result.perChannel, isEmpty);
      expect(result.minAccuracy, 0);
      expect(result.meanAccuracy, 0);
    });

    test('minAccuracy returns the worst per-channel accuracy', () {
      final trials = [
        const Trial(
          index: 0,
          frame: StimulusFrame({
            ChannelType.position: 0,
            ChannelType.audio: 0,
          }),
          isMatch: {
            ChannelType.position: false,
            ChannelType.audio: false,
          },
        ),
        const Trial(
          index: 1,
          frame: StimulusFrame({
            ChannelType.position: 0,
            ChannelType.audio: 0,
          }),
          isMatch: {
            ChannelType.position: true,
            ChannelType.audio: true,
          },
        ),
      ];
      // User pressed only position match. Position: hit (acc=1).
      // Audio: miss (acc=0).
      final result = evaluator.evaluate(
        trials: trials,
        n: 1,
        responses: {
          ChannelType.position: {1},
        },
      );
      expect(result.perChannel[ChannelType.position]!.accuracy, 1.0);
      expect(result.perChannel[ChannelType.audio]!.accuracy, 0.0);
      expect(result.minAccuracy, 0.0);
      expect(result.meanAccuracy, closeTo(0.5, 1e-9));
    });
  });
}
