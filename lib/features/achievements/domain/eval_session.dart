import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:meta/meta.dart';

/// A normalised session input for the achievements evaluator. Keeps the
/// evaluator independent of both the Drift schema (`SavedSession`) and the
/// in-memory game state (`GameSession`/`SessionScore`).
@immutable
class EvalSession {
  const EvalSession({
    required this.startedAt,
    required this.n,
    required this.activeChannels,
    required this.totalTrials,
    required this.perChannel,
  });

  final DateTime startedAt;
  final int n;
  final Set<ChannelType> activeChannels;
  final int totalTrials;
  final Map<ChannelType, EvalChannelScore> perChannel;

  /// Pooled accuracy across all channels:
  /// `sum(hits) / sum(hits + misses + falseAlarms)`.
  double get overallAccuracy {
    if (perChannel.isEmpty) return 0;
    var totalHits = 0;
    var totalEngaged = 0;
    for (final cs in perChannel.values) {
      totalHits += cs.hits;
      totalEngaged += cs.hits + cs.misses + cs.falseAlarms;
    }
    if (totalEngaged == 0) return 0;
    return totalHits / totalEngaged;
  }

  /// Highest d-prime across the active channels, or 0 if none.
  double get maxDPrime {
    if (perChannel.isEmpty) return 0;
    return perChannel.values
        .map((cs) => cs.dPrime)
        .reduce((a, b) => a > b ? a : b);
  }

  /// True if every channel had no misses and no false alarms.
  bool get isPerfect {
    if (perChannel.isEmpty) return false;
    return perChannel.values
        .every((cs) => cs.misses == 0 && cs.falseAlarms == 0);
  }
}

@immutable
class EvalChannelScore {
  const EvalChannelScore({
    required this.hits,
    required this.misses,
    required this.falseAlarms,
    required this.correctRejections,
    required this.accuracy,
    required this.dPrime,
  });

  final int hits;
  final int misses;
  final int falseAlarms;
  final int correctRejections;
  final double accuracy;
  final double dPrime;
}
