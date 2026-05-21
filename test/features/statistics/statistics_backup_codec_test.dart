import 'dart:convert';

import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/statistics/data/database.dart';
import 'package:dual_n_back/features/statistics/data/statistics_backup_codec.dart';
import 'package:dual_n_back/features/statistics/domain/saved_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatisticsBackupCodec.encode', () {
    test('produces an envelope with version, exportedAt and sessions', () {
      final json = jsonDecode(
        StatisticsBackupCodec.encode(
          const [],
          exportedAt: DateTime.utc(2026, 5, 21, 12, 34, 56),
        ),
      ) as Map<String, Object?>;

      expect(json['version'], statisticsBackupVersion);
      expect(json['exportedAt'], '2026-05-21T12:34:56.000Z');
      expect(json['sessions'], isEmpty);
    });

    test('serialises every column and per-channel score', () {
      final session = Session(
        id: 1,
        startedAt: DateTime.utc(2026, 5, 7, 10),
        n: 3,
        newN: 4,
        activeChannels: 'position,audio',
        totalTrials: 22,
        stimulusDurationMs: 500,
        isiMs: 2500,
        minAccuracy: 0.83,
      );
      const score = ChannelScore(
        id: 1,
        sessionId: 1,
        channel: 'position',
        hits: 5,
        misses: 1,
        falseAlarms: 0,
        correctRejections: 14,
        accuracy: 0.83,
        dPrime: 3.5,
      );
      final json = jsonDecode(
        StatisticsBackupCodec.encode(
          [SavedSession(session: session, scores: const [score])],
          exportedAt: DateTime.utc(2026, 5, 21),
        ),
      ) as Map<String, Object?>;

      final sessions = json['sessions']! as List;
      expect(sessions, hasLength(1));
      final s = sessions.first as Map<String, Object?>;
      expect(s['startedAt'], '2026-05-07T10:00:00.000Z');
      expect(s['n'], 3);
      expect(s['newN'], 4);
      expect(s['activeChannels'], ['position', 'audio']);
      expect(s['totalTrials'], 22);
      expect(s['stimulusDurationMs'], 500);
      expect(s['isiMs'], 2500);
      expect(s['minAccuracy'], 0.83);

      final scores = s['scores']! as List;
      expect(scores, hasLength(1));
      final sc = scores.first as Map<String, Object?>;
      expect(sc['channel'], 'position');
      expect(sc['hits'], 5);
      expect(sc['misses'], 1);
      expect(sc['falseAlarms'], 0);
      expect(sc['correctRejections'], 14);
      expect(sc['accuracy'], 0.83);
      expect(sc['dPrime'], 3.5);
    });
  });

  group('StatisticsBackupCodec.decode', () {
    test('round-trips encode → decode', () {
      final session = Session(
        id: 1,
        startedAt: DateTime.utc(2026, 5, 7, 10),
        n: 3,
        newN: 4,
        activeChannels: 'position,audio',
        totalTrials: 22,
        stimulusDurationMs: 500,
        isiMs: 2500,
        minAccuracy: 0.83,
      );
      const scorePosition = ChannelScore(
        id: 1,
        sessionId: 1,
        channel: 'position',
        hits: 5,
        misses: 1,
        falseAlarms: 0,
        correctRejections: 14,
        accuracy: 0.83,
        dPrime: 3.5,
      );
      const scoreAudio = ChannelScore(
        id: 2,
        sessionId: 1,
        channel: 'audio',
        hits: 4,
        misses: 2,
        falseAlarms: 1,
        correctRejections: 13,
        accuracy: 0.57,
        dPrime: 2.1,
      );
      final encoded = StatisticsBackupCodec.encode([
        SavedSession(session: session, scores: const [scorePosition, scoreAudio]),
      ]);
      final seeds = StatisticsBackupCodec.decode(encoded);
      expect(seeds, hasLength(1));
      final seed = seeds.first;
      expect(seed.startedAt, DateTime.utc(2026, 5, 7, 10));
      expect(seed.n, 3);
      expect(seed.newN, 4);
      expect(
        seed.activeChannels,
        {ChannelType.position, ChannelType.audio},
      );
      expect(seed.totalTrials, 22);
      expect(seed.stimulusDurationMs, 500);
      expect(seed.isiMs, 2500);
      final pos = seed.score.perChannel[ChannelType.position]!;
      expect(pos.hits, 5);
      expect(pos.misses, 1);
      expect(pos.falseAlarms, 0);
      expect(pos.correctRejections, 14);
    });

    test('rejects unknown version', () {
      expect(
        () => StatisticsBackupCodec.decode(
          jsonEncode(<String, Object?>{'version': 99, 'sessions': []}),
        ),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects malformed JSON', () {
      expect(
        () => StatisticsBackupCodec.decode('{not json'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects non-object root', () {
      expect(
        () => StatisticsBackupCodec.decode('[]'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('drops unknown channel names but keeps known ones', () {
      final payload = jsonEncode({
        'version': statisticsBackupVersion,
        'exportedAt': '2026-05-21T00:00:00.000Z',
        'sessions': [
          {
            'startedAt': '2026-05-07T10:00:00.000Z',
            'n': 2,
            'newN': 2,
            'activeChannels': ['position', 'mystery'],
            'totalTrials': 22,
            'stimulusDurationMs': 500,
            'isiMs': 2500,
            'minAccuracy': 0.5,
            'scores': [
              {
                'channel': 'position',
                'hits': 1, 'misses': 0, 'falseAlarms': 0,
                'correctRejections': 1, 'accuracy': 1.0, 'dPrime': 1.0,
              },
              {
                'channel': 'mystery',
                'hits': 1, 'misses': 0, 'falseAlarms': 0,
                'correctRejections': 1, 'accuracy': 1.0, 'dPrime': 1.0,
              },
            ],
          },
        ],
      });
      final seeds = StatisticsBackupCodec.decode(payload);
      expect(
        seeds.first.score.perChannel.keys,
        <ChannelType>[ChannelType.position],
      );
      expect(seeds.first.activeChannels, {ChannelType.position});
    });
  });
}
