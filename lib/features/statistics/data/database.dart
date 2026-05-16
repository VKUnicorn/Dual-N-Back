import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// One completed N-back session.
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();

  /// N value used during this session.
  IntColumn get n => integer()();

  /// Recommended next N (after adaptive adjustment, or unchanged if disabled).
  IntColumn get newN => integer()();

  /// Comma-separated `ChannelType.name` values of active channels.
  TextColumn get activeChannels => text()();

  IntColumn get totalTrials => integer()();
  IntColumn get stimulusDurationMs => integer()();
  IntColumn get isiMs => integer()();

  /// Worst per-channel accuracy across the session (Jaeggi score).
  RealColumn get minAccuracy => real()();
}

/// Per-channel score for a single session.
class ChannelScores extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(
        Sessions,
        #id,
        onDelete: KeyAction.cascade,
      )();

  /// `ChannelType.name`.
  TextColumn get channel => text()();

  IntColumn get hits => integer()();
  IntColumn get misses => integer()();
  IntColumn get falseAlarms => integer()();
  IntColumn get correctRejections => integer()();

  RealColumn get accuracy => real()();
  RealColumn get dPrime => real()();
}

@DriftDatabase(tables: [Sessions, ChannelScores])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'dual_n_back');
  }
}
