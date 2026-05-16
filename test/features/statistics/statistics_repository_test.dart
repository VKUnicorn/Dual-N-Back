import 'package:drift/native.dart';
import 'package:dual_n_back/features/game/domain/response_evaluator.dart'
    as domain;
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/statistics/data/database.dart';
import 'package:dual_n_back/features/statistics/data/statistics_repository.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _memoryDb() => AppDatabase(NativeDatabase.memory());

domain.SessionScore _scoreFor(Map<ChannelType, double> accuracies) {
  return domain.SessionScore({
    for (final entry in accuracies.entries)
      entry.key: domain.ChannelScore(
        hits: (entry.value * 10).round(),
        misses: 10 - (entry.value * 10).round(),
        falseAlarms: 0,
        correctRejections: 10,
      ),
  });
}

void main() {
  group('StatisticsRepository', () {
    late AppDatabase db;
    late StatisticsRepository repo;

    setUp(() {
      db = _memoryDb();
      repo = StatisticsRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('saveSession persists session and channel scores', () async {
      final score = _scoreFor({
        ChannelType.position: 0.8,
        ChannelType.audio: 0.6,
      });
      final id = await repo.saveSession(
        startedAt: DateTime(2026, 4, 30, 12),
        n: 3,
        newN: 4,
        activeChannels: {ChannelType.position, ChannelType.audio},
        totalTrials: 23,
        stimulusDurationMs: 500,
        isiMs: 2500,
        score: score,
      );

      expect(id, isPositive);

      final saved = await repo.loadAll();
      expect(saved, hasLength(1));
      expect(saved.first.session.n, 3);
      expect(saved.first.session.newN, 4);
      expect(saved.first.session.totalTrials, 23);
      expect(saved.first.scores, hasLength(2));
      final names = saved.first.scores.map((s) => s.channel).toSet();
      expect(names, {'position', 'audio'});
    });

    test('loadAll returns sessions newest first', () async {
      final now = DateTime(2026, 4);
      for (var i = 0; i < 3; i++) {
        await repo.saveSession(
          startedAt: now.add(Duration(days: i)),
          n: 2 + i,
          newN: 2 + i,
          activeChannels: {ChannelType.position},
          totalTrials: 22,
          stimulusDurationMs: 500,
          isiMs: 2500,
          score: _scoreFor({ChannelType.position: 0.7}),
        );
      }

      final saved = await repo.loadAll();
      expect(saved.map((s) => s.session.n).toList(), [4, 3, 2]);
    });

    test('clearAll removes everything', () async {
      await repo.saveSession(
        startedAt: DateTime.now(),
        n: 2,
        newN: 2,
        activeChannels: {ChannelType.position},
        totalTrials: 22,
        stimulusDurationMs: 500,
        isiMs: 2500,
        score: _scoreFor({ChannelType.position: 0.7}),
      );
      expect(await repo.loadAll(), hasLength(1));

      await repo.clearAll();
      expect(await repo.loadAll(), isEmpty);
    });

    test('watchAll emits updates when sessions are inserted', () async {
      final stream = repo.watchAll();
      final emissions = <int>[];
      final sub = stream.listen((sessions) => emissions.add(sessions.length));

      await Future<void>.delayed(const Duration(milliseconds: 10));

      await repo.saveSession(
        startedAt: DateTime.now(),
        n: 2,
        newN: 2,
        activeChannels: {ChannelType.position},
        totalTrials: 22,
        stimulusDurationMs: 500,
        isiMs: 2500,
        score: _scoreFor({ChannelType.position: 0.9}),
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      // Initial emission (empty) plus the post-insert emission.
      expect(emissions, contains(0));
      expect(emissions.last, 1);
    });
  });
}
