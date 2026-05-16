import 'dart:math';

import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/game/domain/trial.dart';

/// Generates a sequence of trials for an N-back session.
///
/// For each channel and each trial `i >= n`:
/// - With probability `matchProbability`, the stimulus equals the value
///   at trial `i - n` (this is a match).
/// - Otherwise, the stimulus is uniformly random among values that are
///   NOT equal to the value at `i - n` (a guaranteed non-match).
///
/// Channels are independent: a match on `position` does not imply a match
/// on `audio`, etc. This matches the standard Jaeggi protocol.
class StimulusGenerator {
  StimulusGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<Trial> generate({
    required int n,
    required int trialCount,
    required Set<ChannelType> activeChannels,
    double matchProbability = 0.3,
    Map<ChannelType, int> cardinalityOverrides = const {},
  }) {
    if (n < 1) {
      throw ArgumentError.value(n, 'n', 'must be >= 1');
    }
    if (trialCount <= n) {
      throw ArgumentError.value(
        trialCount,
        'trialCount',
        'must be greater than n ($n)',
      );
    }
    if (activeChannels.isEmpty) {
      throw ArgumentError.value(
        activeChannels,
        'activeChannels',
        'must not be empty',
      );
    }
    if (matchProbability < 0 || matchProbability > 1) {
      throw ArgumentError.value(
        matchProbability,
        'matchProbability',
        'must be in [0, 1]',
      );
    }

    int cardinalityOf(ChannelType c) =>
        cardinalityOverrides[c] ?? c.cardinality;

    final trials = <Trial>[];

    // Generate `n` warm-up trials with no possible match.
    for (var i = 0; i < n; i++) {
      final values = <ChannelType, int>{};
      final isMatch = <ChannelType, bool>{};
      for (final channel in activeChannels) {
        values[channel] = _random.nextInt(cardinalityOf(channel));
        isMatch[channel] = false;
      }
      trials.add(
        Trial(
          index: i,
          frame: StimulusFrame(values),
          isMatch: isMatch,
        ),
      );
    }

    // Generate the rest, with controlled match probability per channel.
    for (var i = n; i < trialCount; i++) {
      final values = <ChannelType, int>{};
      final isMatch = <ChannelType, bool>{};
      for (final channel in activeChannels) {
        final reference = trials[i - n].frame[channel];
        final shouldMatch = _random.nextDouble() < matchProbability;
        if (shouldMatch) {
          values[channel] = reference;
          isMatch[channel] = true;
        } else {
          values[channel] =
              _randomDifferent(cardinalityOf(channel), reference);
          isMatch[channel] = false;
        }
      }
      trials.add(
        Trial(
          index: i,
          frame: StimulusFrame(values),
          isMatch: isMatch,
        ),
      );
    }

    return trials;
  }

  /// Picks a uniformly random integer in [0, cardinality) that is not equal
  /// to [exclude]. Requires cardinality >= 2.
  int _randomDifferent(int cardinality, int exclude) {
    if (cardinality < 2) {
      throw StateError(
        'Cannot pick a value different from $exclude '
        'when cardinality is $cardinality.',
      );
    }
    final picked = _random.nextInt(cardinality - 1);
    return picked >= exclude ? picked + 1 : picked;
  }
}
