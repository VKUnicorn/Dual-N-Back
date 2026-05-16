import 'package:dual_n_back/features/achievements/domain/eval_session.dart';
import 'package:dual_n_back/features/game/domain/game_session.dart';
import 'package:dual_n_back/features/game/domain/response_evaluator.dart'
    as domain;
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/statistics/data/database.dart' as db;
import 'package:dual_n_back/features/statistics/domain/saved_session.dart';

/// Bridges persistence (`SavedSession`) and in-memory game state
/// (`GameSession` + `SessionScore`) into the pure-Dart [EvalSession]
/// consumed by the achievements evaluator.
abstract final class EvalSessionAdapter {
  /// Builds an [EvalSession] from a stored [SavedSession]. Channel scores
  /// are read straight from the persisted columns (no recomputation).
  static EvalSession fromSaved(SavedSession saved) {
    final activeChannels = _parseChannels(saved.session.activeChannels);
    final perChannel = <ChannelType, EvalChannelScore>{};
    for (final cs in saved.scores) {
      final channel = _channelFromName(cs.channel);
      if (channel == null) continue;
      perChannel[channel] = _fromDbScore(cs);
    }
    return EvalSession(
      startedAt: saved.session.startedAt,
      n: saved.session.n,
      activeChannels: activeChannels,
      // Achievements count *scored* trials only — warm-up trials at the
      // start of the session don't have an n-back reference and never
      // produce hits/misses, so they shouldn't tick milestone counters.
      // The DB column stores the full trial count (used for accurate
      // training-time bookkeeping), so subtract `n` here.
      totalTrials: _scoredTrials(saved.session.totalTrials, saved.session.n),
      perChannel: perChannel,
    );
  }

  /// Synthesises an [EvalSession] for the just-finished session, using the
  /// [score] computed in `_finish()` and the supplied [startedAt] (the
  /// achievements pipeline uses the same `DateTime.now()` it later passes
  /// to `saveSession` so the synthesised entry matches the persisted one).
  static EvalSession fromCurrent({
    required GameSession session,
    required domain.SessionScore score,
    required DateTime startedAt,
  }) {
    return EvalSession(
      startedAt: startedAt,
      n: session.n,
      activeChannels: session.activeChannels,
      totalTrials: _scoredTrials(session.trials.length, session.n),
      perChannel: {
        for (final entry in score.perChannel.entries)
          entry.key: _fromDomainScore(entry.value),
      },
    );
  }

  static int _scoredTrials(int totalTrials, int n) {
    final scored = totalTrials - n;
    return scored < 0 ? 0 : scored;
  }

  static EvalChannelScore _fromDbScore(db.ChannelScore cs) => EvalChannelScore(
        hits: cs.hits,
        misses: cs.misses,
        falseAlarms: cs.falseAlarms,
        correctRejections: cs.correctRejections,
        accuracy: cs.accuracy,
        dPrime: cs.dPrime,
      );

  static EvalChannelScore _fromDomainScore(domain.ChannelScore cs) =>
      EvalChannelScore(
        hits: cs.hits,
        misses: cs.misses,
        falseAlarms: cs.falseAlarms,
        correctRejections: cs.correctRejections,
        accuracy: cs.accuracy,
        dPrime: cs.dPrime,
      );

  static Set<ChannelType> _parseChannels(String csv) {
    if (csv.isEmpty) return const {};
    final result = <ChannelType>{};
    for (final name in csv.split(',')) {
      final c = _channelFromName(name);
      if (c != null) result.add(c);
    }
    return result;
  }

  static ChannelType? _channelFromName(String name) {
    for (final c in ChannelType.values) {
      if (c.name == name) return c;
    }
    return null;
  }
}
