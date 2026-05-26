import 'dart:math';

import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/game/domain/trial.dart';

/// Generates a sequence of trials for an N-back session.
///
/// Match selection is *count-based*, not coin-flip-based: for each channel
/// we pick a fixed number of match positions ahead of time and distribute
/// them uniformly at random across the scoring trials. This guarantees the
/// promised match count per session (avoiding the legacy edge case where a
/// run of Bernoulli "no-match" rolls left a channel with zero matches and
/// the player stuck at 0% accuracy through no fault of their own), while
/// still matching the spirit of the Jaeggi protocol — ~30% targets per
/// channel on a 20-trial block ≈ 6 matches.
///
/// Algorithm per channel:
/// - `base = ceil(scoringTrials * matchProbability)`, minimum 1
/// - `jitter = floor(base * matchProbabilityJitter)`
/// - Roll a uniform integer offset in `[-jitter, +jitter]`
/// - `actualMatches = clamp(base + offset, 1, scoringTrials)`
/// - Pick `actualMatches` distinct scoring-trial positions uniformly at
///   random; those positions match, the rest do not.
///
/// The jitter exists so the player can't infer from "matches happened
/// already" that the rest of the session is safe.
///
/// Channels are independent: a match on `position` does not imply a match
/// on `audio`, etc. — each channel rolls its own offset and its own
/// match-position set.
class StimulusGenerator {
  StimulusGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Tolerance used to neutralise double-precision noise on the
  /// `scoringCount * matchProbability` product before ceiling. Small
  /// enough not to swallow any user-meaningful step (the UI slider step
  /// is 0.05 = 5%), large enough to absorb the IEEE-754 rounding error
  /// of products of decimal slider values. Exposed so the settings hint
  /// can show the exact match count the generator will produce.
  static const double matchCeilEpsilon = 1e-9;

  List<Trial> generate({
    required int n,
    required int trialCount,
    required Set<ChannelType> activeChannels,
    double matchProbability = 0.3,
    double matchProbabilityJitter = 0.2,
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
    if (matchProbabilityJitter < 0 || matchProbabilityJitter > 1) {
      throw ArgumentError.value(
        matchProbabilityJitter,
        'matchProbabilityJitter',
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

    // Decide ahead of time which scoring-trial positions are matches
    // for each channel. Scoring positions are 0-based: position `k` here
    // corresponds to trial index `n + k`.
    final scoringCount = trialCount - n;
    // Subtract a small epsilon before ceil so floating-point round-trip
    // noise (e.g. 20 * 0.3 == 6.000000000000001) doesn't bump the target
    // up by a full match — the user expects exactly 6 matches at 30% × 20.
    final base = (scoringCount * matchProbability - matchCeilEpsilon)
        .ceil()
        .clamp(1, scoringCount);
    final jitter = (base * matchProbabilityJitter).floor();

    final matchPositions = <ChannelType, Set<int>>{};
    for (final channel in activeChannels) {
      final offset = jitter > 0 ? _random.nextInt(2 * jitter + 1) - jitter : 0;
      final actual = (base + offset).clamp(1, scoringCount);
      matchPositions[channel] = _pickPositions(scoringCount, actual);
    }

    // Generate the scoring trials honouring the per-channel match-position
    // sets we just computed.
    for (var i = n; i < trialCount; i++) {
      final values = <ChannelType, int>{};
      final isMatch = <ChannelType, bool>{};
      final scoringPos = i - n;
      for (final channel in activeChannels) {
        final reference = trials[i - n].frame[channel];
        final shouldMatch = matchPositions[channel]!.contains(scoringPos);
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

  /// Picks [count] distinct integers uniformly from `[0, total)`.
  /// Requires `0 <= count <= total`. Uses a partial Fisher-Yates shuffle.
  Set<int> _pickPositions(int total, int count) {
    if (count >= total) {
      return {for (var i = 0; i < total; i++) i};
    }
    final indices = List<int>.generate(total, (i) => i)..shuffle(_random);
    return indices.take(count).toSet();
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
