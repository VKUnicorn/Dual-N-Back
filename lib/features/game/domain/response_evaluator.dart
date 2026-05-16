import 'dart:math' as math;

import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/game/domain/trial.dart';
import 'package:meta/meta.dart';

/// Per-channel signal-detection counts.
@immutable
class ChannelScore {
  const ChannelScore({
    required this.hits,
    required this.misses,
    required this.falseAlarms,
    required this.correctRejections,
  });

  /// Match was present, user pressed.
  final int hits;

  /// Match was present, user did not press.
  final int misses;

  /// No match, user pressed.
  final int falseAlarms;

  /// No match, user did not press.
  final int correctRejections;

  int get totalSignals => hits + misses;
  int get totalNoise => falseAlarms + correctRejections;
  int get total => totalSignals + totalNoise;

  /// Number of "engaged" decisions — situations where the player either
  /// should have pressed (signal present) or did press (correct or not).
  /// Correct rejections are excluded as a "free" outcome of inaction.
  int get engagedDecisions => hits + misses + falseAlarms;

  /// Accuracy = `hits / (hits + misses + falseAlarms)`.
  ///
  /// Excludes correct rejections so that pure inaction does not produce
  /// a high score from the prevalence of no-match trials. Equivalent to
  /// the threat score / Jaccard index for binary classification.
  /// Returns 0 when there are no engaged decisions (player neither
  /// pressed nor needed to press).
  double get accuracy {
    if (engagedDecisions == 0) return 0;
    return hits / engagedDecisions;
  }

  /// Hit rate (sensitivity).
  double get hitRate => totalSignals == 0 ? 0 : hits / totalSignals;

  /// False alarm rate.
  double get falseAlarmRate =>
      totalNoise == 0 ? 0 : falseAlarms / totalNoise;

  /// d' (d-prime) using the log-linear correction (Hautus, 1995) to avoid
  /// infinities at extreme rates: add 0.5 to hits/false alarms and 1 to the
  /// totals before computing rates.
  double get dPrime {
    final adjustedHitRate = (hits + 0.5) / (totalSignals + 1);
    final adjustedFaRate = (falseAlarms + 0.5) / (totalNoise + 1);
    return _zScore(adjustedHitRate) - _zScore(adjustedFaRate);
  }

  @override
  String toString() =>
      'ChannelScore(h:$hits m:$misses fa:$falseAlarms cr:$correctRejections '
      'acc:${accuracy.toStringAsFixed(3)} dp:${dPrime.toStringAsFixed(3)})';
}

/// Aggregated session result across all active channels.
@immutable
class SessionScore {
  const SessionScore(this.perChannel);

  final Map<ChannelType, ChannelScore> perChannel;

  /// Worst per-channel accuracy across the session — used by the Jaeggi
  /// protocol to decide whether to advance N.
  double get minAccuracy {
    if (perChannel.isEmpty) return 0;
    return perChannel.values
        .map((s) => s.accuracy)
        .reduce((a, b) => a < b ? a : b);
  }

  /// Mean accuracy across channels — informational.
  double get meanAccuracy {
    if (perChannel.isEmpty) return 0;
    final sum = perChannel.values
        .map((s) => s.accuracy)
        .reduce((a, b) => a + b);
    return sum / perChannel.length;
  }

  /// Overall accuracy across all (channel × scoring trial) decisions:
  /// `sum(hits) / sum(hits + misses + falseAlarms)` over all channels.
  /// Same definition as [ChannelScore.accuracy] but pooled across
  /// channels — equivalent to [meanAccuracy] when every channel has
  /// the same engaged-decision count, more robust otherwise.
  double get overallAccuracy {
    if (perChannel.isEmpty) return 0;
    final totalHits =
        perChannel.values.fold<int>(0, (a, s) => a + s.hits);
    final totalEngaged = perChannel.values
        .fold<int>(0, (a, s) => a + s.engagedDecisions);
    if (totalEngaged == 0) return 0;
    return totalHits / totalEngaged;
  }

  @override
  String toString() => 'SessionScore($perChannel)';
}

/// Evaluates user responses against the ground truth in the trial list.
///
/// `responses` maps each channel to the set of trial indices where the user
/// pressed the "match" button for that channel. A trial counts toward the
/// score only if a match is theoretically possible for that channel
/// (i.e., index >= n). The first n trials are excluded from scoring because
/// no n-back reference exists yet.
class ResponseEvaluator {
  const ResponseEvaluator();

  SessionScore evaluate({
    required List<Trial> trials,
    required int n,
    required Map<ChannelType, Set<int>> responses,
  }) {
    if (trials.isEmpty) {
      return const SessionScore({});
    }
    final activeChannels = trials.first.frame.channels.toSet();

    final result = <ChannelType, ChannelScore>{};
    for (final channel in activeChannels) {
      var hits = 0;
      var misses = 0;
      var falseAlarms = 0;
      var correctRejections = 0;
      final pressed = responses[channel] ?? const <int>{};

      for (final trial in trials) {
        if (trial.index < n) continue; // warm-up
        final actual = trial.isMatchOn(channel);
        final pressedHere = pressed.contains(trial.index);
        if (actual && pressedHere) {
          hits++;
        } else if (actual && !pressedHere) {
          misses++;
        } else if (!actual && pressedHere) {
          falseAlarms++;
        } else {
          correctRejections++;
        }
      }

      result[channel] = ChannelScore(
        hits: hits,
        misses: misses,
        falseAlarms: falseAlarms,
        correctRejections: correctRejections,
      );
    }

    return SessionScore(result);
  }
}

/// Inverse standard-normal CDF (probit) approximation
/// using Acklam's algorithm. Accurate to ~1.15e-9.
double _zScore(double p) {
  if (p <= 0 || p >= 1) {
    throw ArgumentError.value(p, 'p', 'must be in (0, 1)');
  }
  const a = [
    -3.969683028665376e+01,
    2.209460984245205e+02,
    -2.759285104469687e+02,
    1.383577518672690e+02,
    -3.066479806614716e+01,
    2.506628277459239e+00,
  ];
  const b = [
    -5.447609879822406e+01,
    1.615858368580409e+02,
    -1.556989798598866e+02,
    6.680131188771972e+01,
    -1.328068155288572e+01,
  ];
  const c = [
    -7.784894002430293e-03,
    -3.223964580411365e-01,
    -2.400758277161838e+00,
    -2.549732539343734e+00,
    4.374664141464968e+00,
    2.938163982698783e+00,
  ];
  const d = [
    7.784695709041462e-03,
    3.224671290700398e-01,
    2.445134137142996e+00,
    3.754408661907416e+00,
  ];
  const pLow = 0.02425;
  const pHigh = 1 - pLow;

  double q;
  double r;

  if (p < pLow) {
    q = math.sqrt(-2 * math.log(p));
    return (((((c[0] * q + c[1]) * q + c[2]) * q + c[3]) * q + c[4]) * q +
            c[5]) /
        ((((d[0] * q + d[1]) * q + d[2]) * q + d[3]) * q + 1);
  }
  if (p <= pHigh) {
    q = p - 0.5;
    r = q * q;
    return (((((a[0] * r + a[1]) * r + a[2]) * r + a[3]) * r + a[4]) * r +
            a[5]) *
        q /
        (((((b[0] * r + b[1]) * r + b[2]) * r + b[3]) * r + b[4]) * r + 1);
  }
  q = math.sqrt(-2 * math.log(1 - p));
  return -(((((c[0] * q + c[1]) * q + c[2]) * q + c[3]) * q + c[4]) * q +
          c[5]) /
      ((((d[0] * q + d[1]) * q + d[2]) * q + d[3]) * q + 1);
}
