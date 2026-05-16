import 'dart:math';

import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/game/domain/stimulus_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StimulusGenerator', () {
    test('rejects invalid arguments', () {
      final gen = StimulusGenerator(random: Random(0));

      expect(
        () => gen.generate(
          n: 0,
          trialCount: 10,
          activeChannels: {ChannelType.position},
        ),
        throwsArgumentError,
      );
      expect(
        () => gen.generate(
          n: 2,
          trialCount: 2,
          activeChannels: {ChannelType.position},
        ),
        throwsArgumentError,
      );
      expect(
        () => gen.generate(
          n: 2,
          trialCount: 10,
          activeChannels: const {},
        ),
        throwsArgumentError,
      );
      expect(
        () => gen.generate(
          n: 2,
          trialCount: 10,
          activeChannels: {ChannelType.position},
          matchProbability: 1.5,
        ),
        throwsArgumentError,
      );
    });

    test('produces requested number of trials', () {
      final gen = StimulusGenerator(random: Random(42));
      final trials = gen.generate(
        n: 2,
        trialCount: 22,
        activeChannels: {ChannelType.position, ChannelType.audio},
      );
      expect(trials.length, 22);
      expect(trials.first.index, 0);
      expect(trials.last.index, 21);
    });

    test('first n trials are never matches', () {
      final gen = StimulusGenerator(random: Random(7));
      const n = 3;
      final trials = gen.generate(
        n: n,
        trialCount: 25,
        activeChannels: ChannelType.values.toSet(),
      );
      for (var i = 0; i < n; i++) {
        for (final channel in ChannelType.values) {
          expect(trials[i].isMatchOn(channel), isFalse);
        }
      }
    });

    test('isMatch ground truth matches actual frame values', () {
      final gen = StimulusGenerator(random: Random(123));
      const n = 2;
      final trials = gen.generate(
        n: n,
        trialCount: 30,
        activeChannels: {ChannelType.position, ChannelType.color},
      );
      for (var i = n; i < trials.length; i++) {
        for (final channel in [ChannelType.position, ChannelType.color]) {
          final isMatch = trials[i].frame[channel] == trials[i - n].frame[channel];
          expect(
            trials[i].isMatchOn(channel),
            isMatch,
            reason: 'trial $i, channel $channel',
          );
        }
      }
    });

    test('match probability ≈ matchProbability over many trials', () {
      // With seeded random and many trials, observed rate should be close.
      final gen = StimulusGenerator(random: Random(1));
      const n = 2;
      const trialCount = 2002;
      const probability = 0.4;
      final trials = gen.generate(
        n: n,
        trialCount: trialCount,
        activeChannels: {ChannelType.position},
        matchProbability: probability,
      );
      final scoringTrials = trials.skip(n);
      final matches = scoringTrials
          .where((t) => t.isMatchOn(ChannelType.position))
          .length;
      final rate = matches / scoringTrials.length;
      expect(rate, closeTo(probability, 0.05));
    });

    test('channels are independent', () {
      // Position and audio matches should not be correlated.
      final gen = StimulusGenerator(random: Random(99));
      const n = 2;
      final trials = gen.generate(
        n: n,
        trialCount: 1002,
        activeChannels: {ChannelType.position, ChannelType.audio},
      );
      final scoring = trials.skip(n).toList();
      final posMatches = scoring
          .where((t) => t.isMatchOn(ChannelType.position))
          .toSet()
          .map((t) => t.index)
          .toSet();
      final audioMatches = scoring
          .where((t) => t.isMatchOn(ChannelType.audio))
          .toSet()
          .map((t) => t.index)
          .toSet();
      // If independent with p=0.3, P(both) ≈ 0.09, so intersection should be
      // far smaller than either set alone.
      final both = posMatches.intersection(audioMatches).length;
      expect(both, lessThan(posMatches.length));
      expect(both, lessThan(audioMatches.length));
    });

    test('with seeded RNG, output is deterministic', () {
      final gen1 = StimulusGenerator(random: Random(2024));
      final gen2 = StimulusGenerator(random: Random(2024));
      final trials1 = gen1.generate(
        n: 2,
        trialCount: 10,
        activeChannels: {ChannelType.position},
      );
      final trials2 = gen2.generate(
        n: 2,
        trialCount: 10,
        activeChannels: {ChannelType.position},
      );
      for (var i = 0; i < trials1.length; i++) {
        expect(
          trials1[i].frame[ChannelType.position],
          trials2[i].frame[ChannelType.position],
        );
      }
    });
  });
}
