import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/statistics/data/database.dart';
import 'package:dual_n_back/features/statistics/domain/saved_session.dart';
import 'package:dual_n_back/features/statistics/domain/stats_period.dart';

/// Pure-Dart aggregation helpers for the statistics screen. No Flutter
/// imports here — keeps the module trivially unit-testable.

/// Overall accuracy for a saved session.
///
/// Uses each channel's persisted `accuracy` snapshot rather than
/// recomputing from the raw counters. This is deliberate: the formula
/// behind `accuracy` has changed over time, and reading the snapshot
/// keeps already-saved sessions displaying the value they had when
/// finished — newer sessions naturally show the newer formula.
///
/// Channels are pooled by weighting each accuracy by its *engaged*
/// decision count (hits + misses + falseAlarms — same as
/// `ChannelScore.engagedDecisions` in the domain model). This makes
/// the pooled value mathematically identical to
/// `SessionScore.overallAccuracy` on the result screen
/// (`sum(hits) / sum(engaged)`), so the statistics tile and the
/// just-finished result page never disagree on the same session.
double overallAccuracy(List<ChannelScore> scores) {
  if (scores.isEmpty) return 0;
  var weightedSum = 0.0;
  var weight = 0;
  for (final s in scores) {
    final engaged = s.hits + s.misses + s.falseAlarms;
    weightedSum += s.accuracy * engaged;
    weight += engaged;
  }
  if (weight == 0) return 0;
  return weightedSum / weight;
}

int engagedTotal(ChannelScore sc) =>
    sc.hits + sc.misses + sc.falseAlarms + sc.correctRejections;

/// Aggregated value for a single x-axis bucket.
class Bucket {
  Bucket();
  int sessions = 0;
  // Accumulators for weighted-mean overall accuracy across the bucket.
  double accSum = 0;
  int accWeight = 0;
  int maxN = 0;
  // Mean d′ accumulator: each per-channel score contributes its dPrime
  // weighted by total decisions on that channel — same pooling as for
  // accuracy so single-channel sessions don't dominate Dual ones.
  double dpSum = 0;
  int dpWeight = 0;
  // Per-channel accuracy accumulators (same pooling per channel).
  Map<ChannelType, double> channelAccSum = {};
  Map<ChannelType, int> channelAccWeight = {};
}

List<Bucket> bucketize(
  StatsPeriod period,
  StatsRange range,
  List<SavedSession> sessions,
) {
  final n = range.bucketCount(period);
  final buckets = List.generate(n, (_) => Bucket());
  for (final s in sessions) {
    final i = range.bucketIndexFor(period, s.session.startedAt);
    if (i < 0 || i >= n) continue;
    final b = buckets[i]
      ..sessions += 1;
    if (s.session.n > b.maxN) b.maxN = s.session.n;
    final acc = overallAccuracy(s.scores);
    final total = s.scores.fold<int>(0, (sum, sc) => sum + engagedTotal(sc));
    if (total > 0) {
      b
        ..accSum += acc * total
        ..accWeight += total;
    }
    for (final score in s.scores) {
      final w = engagedTotal(score);
      if (w == 0) continue;
      b
        ..dpSum += score.dPrime * w
        ..dpWeight += w;
      final ch = ChannelType.values.firstWhere(
        (c) => c.name == score.channel,
        orElse: () => ChannelType.position,
      );
      b.channelAccSum[ch] = (b.channelAccSum[ch] ?? 0) + score.accuracy * w;
      b.channelAccWeight[ch] = (b.channelAccWeight[ch] ?? 0) + w;
    }
  }
  return buckets;
}

/// Channels that appeared in any session in the visible range — drives
/// which lines the per-channel accuracy chart shows.
Set<ChannelType> activeChannels(List<SavedSession> sessions) {
  final out = <ChannelType>{};
  for (final s in sessions) {
    for (final score in s.scores) {
      for (final c in ChannelType.values) {
        if (c.name == score.channel) {
          out.add(c);
          break;
        }
      }
    }
  }
  return out;
}

/// Read-only summary of the visible range. Computed once per build of the
/// statistics screen and passed down to the summary card.
class PeriodSummary {
  const PeriodSummary({
    required this.bestSession,
    required this.bestAccuracy,
    required this.totalTrials,
    required this.totalTrainingMs,
    required this.daysAchievedGoal,
    required this.totalDays,
    required this.dailyGoal,
    required this.sessionsInPeriod,
    required this.averageAccuracy,
    required this.averageDPrime,
    required this.perChannelAccuracy,
    required this.maxN,
  });

  final SavedSession? bestSession;
  final double bestAccuracy; // 0..1
  final int totalTrials;
  final int totalTrainingMs;
  final int daysAchievedGoal;
  final int totalDays;
  final int dailyGoal;
  final int sessionsInPeriod;

  /// Pooled overall accuracy across every session in the period
  /// (`sum(hits) / sum(engaged)`). 0..1.
  final double averageAccuracy;

  /// Pooled d′ across every channel-trial in the period, each channel
  /// weighted by its total decisions — same pooling as the line chart.
  final double averageDPrime;

  /// Per-channel accuracy (0..1), pooled the same way per channel.
  /// Channels that never appeared in the period are absent from the map.
  final Map<ChannelType, double> perChannelAccuracy;

  /// Highest N reached across any session in the period (0 if empty).
  final int maxN;
}

PeriodSummary summarize(
  StatsRange range,
  List<SavedSession> inRange,
  int dailyGoal,
) {
  SavedSession? best;
  var bestAcc = -1.0;
  var bestN = -1;
  var bestScore = -1.0;
  var totalTrials = 0;
  var totalMs = 0;
  var maxN = 0;
  var accSum = 0.0;
  var accWeight = 0;
  var dpSum = 0.0;
  var dpWeight = 0;
  final perChannelAccSum = <ChannelType, double>{};
  final perChannelAccWeight = <ChannelType, int>{};
  final perDay = <DateTime, int>{};
  for (final s in inRange) {
    final acc = overallAccuracy(s.scores);
    if (s.session.n > maxN) maxN = s.session.n;
    final engagedSum =
        s.scores.fold<int>(0, (sum, sc) => sum + engagedTotal(sc));
    if (engagedSum > 0) {
      accSum += acc * engagedSum;
      accWeight += engagedSum;
    }
    for (final score in s.scores) {
      final w = engagedTotal(score);
      if (w == 0) continue;
      dpSum += score.dPrime * w;
      dpWeight += w;
      final ch = ChannelType.values.firstWhere(
        (c) => c.name == score.channel,
        orElse: () => ChannelType.position,
      );
      perChannelAccSum[ch] =
          (perChannelAccSum[ch] ?? 0) + score.accuracy * w;
      perChannelAccWeight[ch] = (perChannelAccWeight[ch] ?? 0) + w;
    }
    // "Effective N": N weighted by accuracy. A flawless N=9 (score=9)
    // beats a 50%-N=10 (score=5), but a 91%-N=10 (≈9.1) just edges out a
    // perfect N=9. Tie-breakers favour the higher-N session (harder
    // task) and then higher raw accuracy.
    final score = s.session.n * acc;
    final better = score > bestScore ||
        (score == bestScore && s.session.n > bestN) ||
        (score == bestScore && s.session.n == bestN && acc > bestAcc);
    if (better) {
      best = s;
      bestScore = score;
      bestN = s.session.n;
      bestAcc = acc;
    }
    // Display "total trials" excludes the N warm-up trials at the start
    // of each session — those have no n-back reference and aren't scored.
    // Training time, in contrast, keeps the full count: warm-ups still
    // occupy real wall-clock time on screen.
    final scored = s.session.totalTrials - s.session.n;
    totalTrials += scored < 0 ? 0 : scored;
    totalMs += s.session.totalTrials *
        (s.session.stimulusDurationMs + s.session.isiMs);
    final d = s.session.startedAt;
    final key = DateTime(d.year, d.month, d.day);
    perDay[key] = (perDay[key] ?? 0) + 1;
  }
  // Cap "total days" at today — counting future calendar days inside the
  // visible period as misses would always shave the daily-goal rate.
  // `range.end` is exclusive (first moment of the *next* period), so the
  // raw difference is already the correct day count when the period is
  // entirely in the past. For an in-progress period we clamp to the day
  // *after* today (so today itself counts).
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final endExclusive = range.end.isAfter(tomorrow) ? tomorrow : range.end;
  var totalDays = endExclusive.difference(range.start).inDays;
  if (totalDays < 0) totalDays = 0;
  var achieved = 0;
  for (final entry in perDay.entries) {
    if (entry.value >= dailyGoal) achieved += 1;
  }
  final perChannelAcc = <ChannelType, double>{};
  for (final entry in perChannelAccSum.entries) {
    final w = perChannelAccWeight[entry.key] ?? 0;
    if (w == 0) continue;
    perChannelAcc[entry.key] = entry.value / w;
  }
  return PeriodSummary(
    bestSession: best,
    bestAccuracy: bestAcc < 0 ? 0 : bestAcc,
    totalTrials: totalTrials,
    totalTrainingMs: totalMs,
    daysAchievedGoal: achieved,
    totalDays: totalDays,
    dailyGoal: dailyGoal,
    sessionsInPeriod: inRange.length,
    averageAccuracy: accWeight == 0 ? 0 : accSum / accWeight,
    averageDPrime: dpWeight == 0 ? 0 : dpSum / dpWeight,
    perChannelAccuracy: perChannelAcc,
    maxN: maxN,
  );
}
