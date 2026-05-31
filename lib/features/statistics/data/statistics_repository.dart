import 'package:drift/drift.dart';
import 'package:dual_n_back/features/game/domain/response_evaluator.dart'
    as domain;
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/statistics/data/database.dart';
import 'package:dual_n_back/features/statistics/domain/saved_session.dart';

/// Persists and reads completed N-back sessions.
class StatisticsRepository {
  StatisticsRepository(this._db);

  final AppDatabase _db;

  /// Inserts a completed session and its per-channel scores in one
  /// transaction. Returns the new session id.
  Future<int> saveSession({
    required DateTime startedAt,
    required int n,
    required int newN,
    required Set<ChannelType> activeChannels,
    required int totalTrials,
    required int stimulusDurationMs,
    required int isiMs,
    required domain.SessionScore score,
    String? profileId,
    String? profileName,
  }) {
    return _db.transaction(() async {
      final sessionId = await _db.into(_db.sessions).insert(
            SessionsCompanion.insert(
              startedAt: startedAt,
              n: n,
              newN: newN,
              activeChannels:
                  activeChannels.map((c) => c.name).toList().join(','),
              totalTrials: totalTrials,
              stimulusDurationMs: stimulusDurationMs,
              isiMs: isiMs,
              minAccuracy: score.minAccuracy,
              profileId: Value(profileId),
              profileName: Value(profileName),
            ),
          );
      for (final entry in score.perChannel.entries) {
        await _db.into(_db.channelScores).insert(
              ChannelScoresCompanion.insert(
                sessionId: sessionId,
                channel: entry.key.name,
                hits: entry.value.hits,
                misses: entry.value.misses,
                falseAlarms: entry.value.falseAlarms,
                correctRejections: entry.value.correctRejections,
                accuracy: entry.value.accuracy,
                dPrime: entry.value.dPrime,
              ),
            );
      }
      return sessionId;
    });
  }

  /// All sessions, newest first, with their per-channel scores.
  Future<List<SavedSession>> loadAll() async {
    final sessions = await (_db.select(_db.sessions)
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
        .get();
    if (sessions.isEmpty) return const [];

    final scores = await (_db.select(_db.channelScores)
          ..where((c) => c.sessionId.isIn(sessions.map((s) => s.id))))
        .get();

    final byId = <int, List<ChannelScore>>{};
    for (final score in scores) {
      byId.putIfAbsent(score.sessionId, () => []).add(score);
    }

    return [
      for (final s in sessions)
        SavedSession(session: s, scores: byId[s.id] ?? const []),
    ];
  }

  /// Stream that emits the full history every time it changes.
  Stream<List<SavedSession>> watchAll() {
    final query = _db.select(_db.sessions)
      ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]);
    return query.watch().asyncMap((sessions) async {
      if (sessions.isEmpty) return <SavedSession>[];
      final scores = await (_db.select(_db.channelScores)
            ..where((c) => c.sessionId.isIn(sessions.map((s) => s.id))))
          .get();
      final byId = <int, List<ChannelScore>>{};
      for (final score in scores) {
        byId.putIfAbsent(score.sessionId, () => []).add(score);
      }
      return [
        for (final s in sessions)
          SavedSession(session: s, scores: byId[s.id] ?? const []),
      ];
    });
  }

  Future<void> clearAll() async {
    await _db.transaction(() async {
      await _db.delete(_db.channelScores).go();
      await _db.delete(_db.sessions).go();
    });
  }

  /// Removes a single session and its per-channel scores. The
  /// `ChannelScores` foreign key is `onDelete: cascade` so deleting the
  /// session row is enough — drift cleans up the children automatically.
  Future<void> deleteSession(int id) async {
    await (_db.delete(_db.sessions)..where((s) => s.id.equals(id))).go();
  }

  /// Inserts a batch of pre-built sessions (with their per-channel scores)
  /// in a single transaction. Used by the in-app debug button to seed
  /// historical data; not meant for production code paths.
  Future<void> bulkInsert(List<FakeSessionSeed> seeds) async {
    if (seeds.isEmpty) return;
    await _db.transaction(() async {
      for (final seed in seeds) {
        final id = await _db.into(_db.sessions).insert(
              SessionsCompanion.insert(
                startedAt: seed.startedAt,
                n: seed.n,
                newN: seed.newN,
                activeChannels:
                    seed.activeChannels.map((c) => c.name).toList().join(','),
                totalTrials: seed.totalTrials,
                stimulusDurationMs: seed.stimulusDurationMs,
                isiMs: seed.isiMs,
                minAccuracy: seed.score.minAccuracy,
                profileId: Value(seed.profileId),
                profileName: Value(seed.profileName),
              ),
            );
        for (final entry in seed.score.perChannel.entries) {
          await _db.into(_db.channelScores).insert(
                ChannelScoresCompanion.insert(
                  sessionId: id,
                  channel: entry.key.name,
                  hits: entry.value.hits,
                  misses: entry.value.misses,
                  falseAlarms: entry.value.falseAlarms,
                  correctRejections: entry.value.correctRejections,
                  accuracy: entry.value.accuracy,
                  dPrime: entry.value.dPrime,
                ),
              );
        }
      }
    });
  }
}

/// Plain-data payload used by [StatisticsRepository.bulkInsert].
class FakeSessionSeed {
  const FakeSessionSeed({
    required this.startedAt,
    required this.n,
    required this.newN,
    required this.activeChannels,
    required this.totalTrials,
    required this.stimulusDurationMs,
    required this.isiMs,
    required this.score,
    this.profileId,
    this.profileName,
  });

  final DateTime startedAt;
  final int n;
  final int newN;
  final Set<ChannelType> activeChannels;
  final int totalTrials;
  final int stimulusDurationMs;
  final int isiMs;
  final domain.SessionScore score;
  final String? profileId;
  final String? profileName;
}
