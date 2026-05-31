import 'dart:convert';

import 'package:dual_n_back/features/game/domain/response_evaluator.dart'
    as domain;
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/statistics/data/database.dart';
import 'package:dual_n_back/features/statistics/data/statistics_repository.dart';
import 'package:dual_n_back/features/statistics/domain/saved_session.dart';

/// JSON envelope schema version produced by [StatisticsBackupCodec.encode].
///
/// Bump on any structural change. Importers should reject envelopes whose
/// version they don't understand instead of guessing missing fields.
const int statisticsBackupVersion = 2;

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
///       "profileId": "default", "profileName": "",
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
      // v2: training-profile snapshot. Null for sessions recorded before
      // profiles existed; emitted as JSON null to keep the shape stable.
      'profileId': s.profileId,
      'profileName': s.profileName,
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

  /// Parses a previously-encoded backup string into a list of
  /// [FakeSessionSeed]s ready for [StatisticsRepository.bulkInsert].
  ///
  /// Throws [BackupFormatException] on any structural problem (malformed
  /// JSON, missing fields, unknown version, unparsable date, etc.) so
  /// the caller can present a single localized error message regardless
  /// of which check tripped.
  ///
  /// Per-channel `accuracy` and `dPrime` columns are NOT taken from the
  /// JSON — they're recomputed from the underlying counts by the domain
  /// getters in `bulkInsert`. This keeps imported and freshly-saved
  /// sessions on the exact same numeric basis.
  static List<FakeSessionSeed> decode(String source) {
    final Object? raw;
    try {
      raw = jsonDecode(source);
    } on FormatException catch (e) {
      throw BackupFormatException('invalid JSON: ${e.message}');
    }
    if (raw is! Map<String, Object?>) {
      throw const BackupFormatException('root must be an object');
    }
    final version = raw['version'];
    if (version is! int) {
      throw const BackupFormatException('missing "version"');
    }
    // Accept any version this build understands (1..current). v2 added the
    // optional training-profile fields; older v1 files simply lack them and
    // decode with null profiles.
    if (version < 1 || version > statisticsBackupVersion) {
      throw BackupFormatException(
        'unsupported version $version (expected 1..$statisticsBackupVersion)',
      );
    }
    final sessions = raw['sessions'];
    if (sessions is! List) {
      throw const BackupFormatException('"sessions" must be a list');
    }
    return [
      for (final entry in sessions) _decodeSession(entry),
    ];
  }

  static FakeSessionSeed _decodeSession(Object? raw) {
    if (raw is! Map<String, Object?>) {
      throw const BackupFormatException('session must be an object');
    }
    final startedAtRaw = raw['startedAt'];
    if (startedAtRaw is! String) {
      throw const BackupFormatException('session: missing "startedAt"');
    }
    final DateTime startedAt;
    try {
      startedAt = DateTime.parse(startedAtRaw);
    } on FormatException catch (e) {
      throw BackupFormatException('session: bad "startedAt": ${e.message}');
    }
    final channels = raw['activeChannels'];
    if (channels is! List) {
      throw const BackupFormatException(
        'session: "activeChannels" must be a list',
      );
    }
    final active = <ChannelType>{};
    for (final name in channels) {
      final match = _channelByName(name);
      if (match != null) active.add(match);
    }
    final scoresRaw = raw['scores'];
    if (scoresRaw is! List) {
      throw const BackupFormatException('session: "scores" must be a list');
    }
    final perChannel = <ChannelType, domain.ChannelScore>{};
    for (final entry in scoresRaw) {
      if (entry is! Map<String, Object?>) {
        throw const BackupFormatException('score must be an object');
      }
      final ch = _channelByName(entry['channel']);
      if (ch == null) continue; // ignore unknown channels from future versions
      perChannel[ch] = domain.ChannelScore(
        hits: _readInt(entry, 'hits'),
        misses: _readInt(entry, 'misses'),
        falseAlarms: _readInt(entry, 'falseAlarms'),
        correctRejections: _readInt(entry, 'correctRejections'),
      );
    }
    return FakeSessionSeed(
      startedAt: startedAt,
      n: _readInt(raw, 'n'),
      newN: _readInt(raw, 'newN'),
      activeChannels: active,
      totalTrials: _readInt(raw, 'totalTrials'),
      stimulusDurationMs: _readInt(raw, 'stimulusDurationMs'),
      isiMs: _readInt(raw, 'isiMs'),
      score: domain.SessionScore(perChannel),
      // Optional (v2+). Non-string / absent values decode to null.
      profileId: _readNullableString(raw, 'profileId'),
      profileName: _readNullableString(raw, 'profileName'),
    );
  }

  static String? _readNullableString(Map<String, Object?> m, String key) {
    final v = m[key];
    return v is String ? v : null;
  }

  static int _readInt(Map<String, Object?> m, String key) {
    final v = m[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    throw BackupFormatException('field "$key" must be an integer');
  }

  static ChannelType? _channelByName(Object? raw) {
    if (raw is! String) return null;
    for (final c in ChannelType.values) {
      if (c.name == raw) return c;
    }
    return null;
  }
}

/// Thrown by [StatisticsBackupCodec.decode] when the input doesn't look
/// like a backup file this build can read.
class BackupFormatException implements Exception {
  const BackupFormatException(this.message);

  final String message;

  @override
  String toString() => 'BackupFormatException: $message';
}
