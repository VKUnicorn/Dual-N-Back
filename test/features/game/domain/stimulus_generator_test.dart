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

    test('match count is exactly ceil(scoring*p) when jitter is 0', () {
      // Count-based selection: with jitter disabled, every channel hits
      // the exact target. 20 scoring trials * 0.3 = 6.0 -> 6 matches
      // (NOT 7 — the generator absorbs floating-point round-trip noise
      // so users get the integer they expect from "30% of 20").
      final gen = StimulusGenerator(random: Random(1));
      const n = 2;
      const trialCount = 22; // 20 scoring trials
      final trials = gen.generate(
        n: n,
        trialCount: trialCount,
        activeChannels: {ChannelType.position, ChannelType.audio},
        matchProbabilityJitter: 0,
      );
      final scoringTrials = trials.skip(n);
      for (final channel in [ChannelType.position, ChannelType.audio]) {
        final matches =
            scoringTrials.where((t) => t.isMatchOn(channel)).length;
        expect(matches, 6, reason: 'channel $channel');
      }
    });

    test('non-integer matchProbability rounds up to a whole match', () {
      // 20 * 0.35 = 7.0 (after epsilon-protected ceil) but 20 * 0.36 = 7.2
      // → ceil = 8. Both fall above the strict 6 baseline, so we use
      // 20 * 0.31 = 6.2 → ceil = 7 as the discriminating case.
      final gen = StimulusGenerator(random: Random(7));
      final trials = gen.generate(
        n: 2,
        trialCount: 22,
        activeChannels: {ChannelType.position},
        matchProbability: 0.31,
        matchProbabilityJitter: 0,
      );
      final matches = trials
          .skip(2)
          .where((t) => t.isMatchOn(ChannelType.position))
          .length;
      expect(matches, 7);
    });

    test('jitter keeps match count within ±floor(base*jitter)', () {
      // Default jitter = 0.2, base = ceil(20 * 0.3) = 6 → floor(6 * 0.2) = 1.
      // Over many sessions, every per-channel count must land in [5, 7].
      final gen = StimulusGenerator(random: Random(1));
      const n = 2;
      const trialCount = 22;
      const sessions = 200;
      final counts = <int>{};
      for (var i = 0; i < sessions; i++) {
        final trials = gen.generate(
          n: n,
          trialCount: trialCount,
          activeChannels: {ChannelType.position},
        );
        final matches = trials
            .skip(n)
            .where((t) => t.isMatchOn(ChannelType.position))
            .length;
        expect(matches, inInclusiveRange(5, 7));
        counts.add(matches);
      }
      // With 200 samples we expect to actually exercise the full range.
      expect(counts.length, greaterThan(1));
    });

    test('match count is at least 1 even when math rounds to 0', () {
      // matchProbability=0.0 + ceil would be 0, but the algorithm enforces
      // a per-channel minimum of 1 so accuracy is never structurally 0%.
      final gen = StimulusGenerator(random: Random(1));
      final trials = gen.generate(
        n: 2,
        trialCount: 22,
        activeChannels: {ChannelType.position},
        matchProbability: 0,
      );
      final matches = trials
          .skip(2)
          .where((t) => t.isMatchOn(ChannelType.position))
          .length;
      expect(matches, 1);
    });

    test('rejects out-of-range matchProbabilityJitter', () {
      final gen = StimulusGenerator(random: Random(0));
      expect(
        () => gen.generate(
          n: 2,
          trialCount: 10,
          activeChannels: {ChannelType.position},
          matchProbabilityJitter: 1.1,
        ),
        throwsArgumentError,
      );
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
