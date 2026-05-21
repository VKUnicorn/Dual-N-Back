import 'dart:convert';

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
}
