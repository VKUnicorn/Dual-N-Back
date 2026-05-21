import 'dart:convert';

import 'package:dual_n_back/features/statistics/data/database.dart';
import 'package:dual_n_back/features/statistics/domain/saved_session.dart';

/// JSON envelope schema version produced by [StatisticsBackupCodec.encode].
///
/// Bump on any structural change. Importers should reject envelopes whose
/// version they don't understand instead of guessing missing fields.
const int statisticsBackupVersion = 1;

/// Pure-Dart encoder for the session history. No I/O, no DB access — the
/// caller passes the rows from `StatisticsRepository.loadAll`.
///
/// Output is a UTF-8-ready JSON string with this shape:
/// ```json
/// {
///   "version": 1,
///   "exportedAt": "2026-05-21T12:34:56.000Z",
///   "sessions": [
///     {
///       "startedAt": "...", "n": 3, "newN": 4,
///       "activeChannels": ["position","audio"],
///       "totalTrials": 22, "stimulusDurationMs": 500, "isiMs": 2500,
///       "minAccuracy": 0.83,
///       "scores": [
///         {"channel": "position", "hits": 5, "misses": 1,
///          "falseAlarms": 0, "correctRejections": 14,
///          "accuracy": 0.83, "dPrime": 3.5}
///       ]
///     }
///   ]
/// }
/// ```
abstract final class StatisticsBackupCodec {
  static String encode(
    List<SavedSession> history, {
    DateTime? exportedAt,
  }) {
    final payload = <String, Object?>{
      'version': statisticsBackupVersion,
      'exportedAt': (exportedAt ?? DateTime.now().toUtc()).toIso8601String(),
      'sessions': [
        for (final entry in history) _encodeSession(entry),
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  static Map<String, Object?> _encodeSession(SavedSession entry) {
    final s = entry.session;
    return {
      'startedAt': s.startedAt.toIso8601String(),
      'n': s.n,
      'newN': s.newN,
      'activeChannels': s.activeChannels.split(','),
      'totalTrials': s.totalTrials,
      'stimulusDurationMs': s.stimulusDurationMs,
      'isiMs': s.isiMs,
      'minAccuracy': s.minAccuracy,
      'scores': [
        for (final score in entry.scores) _encodeScore(score),
      ],
    };
  }

  static Map<String, Object?> _encodeScore(ChannelScore score) {
    return {
      'channel': score.channel,
      'hits': score.hits,
      'misses': score.misses,
      'falseAlarms': score.falseAlarms,
      'correctRejections': score.correctRejections,
      'accuracy': score.accuracy,
      'dPrime': score.dPrime,
    };
  }
}
