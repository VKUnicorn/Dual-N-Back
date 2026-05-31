// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nMeta = const VerificationMeta('n');
  @override
  late final GeneratedColumn<int> n = GeneratedColumn<int>(
    'n',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newNMeta = const VerificationMeta('newN');
  @override
  late final GeneratedColumn<int> newN = GeneratedColumn<int>(
    'new_n',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeChannelsMeta = const VerificationMeta(
    'activeChannels',
  );
  @override
  late final GeneratedColumn<String> activeChannels = GeneratedColumn<String>(
    'active_channels',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalTrialsMeta = const VerificationMeta(
    'totalTrials',
  );
  @override
  late final GeneratedColumn<int> totalTrials = GeneratedColumn<int>(
    'total_trials',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stimulusDurationMsMeta =
      const VerificationMeta('stimulusDurationMs');
  @override
  late final GeneratedColumn<int> stimulusDurationMs = GeneratedColumn<int>(
    'stimulus_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isiMsMeta = const VerificationMeta('isiMs');
  @override
  late final GeneratedColumn<int> isiMs = GeneratedColumn<int>(
    'isi_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minAccuracyMeta = const VerificationMeta(
    'minAccuracy',
  );
  @override
  late final GeneratedColumn<double> minAccuracy = GeneratedColumn<double>(
    'min_accuracy',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profileNameMeta = const VerificationMeta(
    'profileName',
  );
  @override
  late final GeneratedColumn<String> profileName = GeneratedColumn<String>(
    'profile_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    n,
    newN,
    activeChannels,
    totalTrials,
    stimulusDurationMs,
    isiMs,
    minAccuracy,
    profileId,
    profileName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('n')) {
      context.handle(_nMeta, n.isAcceptableOrUnknown(data['n']!, _nMeta));
    } else if (isInserting) {
      context.missing(_nMeta);
    }
    if (data.containsKey('new_n')) {
      context.handle(
        _newNMeta,
        newN.isAcceptableOrUnknown(data['new_n']!, _newNMeta),
      );
    } else if (isInserting) {
      context.missing(_newNMeta);
    }
    if (data.containsKey('active_channels')) {
      context.handle(
        _activeChannelsMeta,
        activeChannels.isAcceptableOrUnknown(
          data['active_channels']!,
          _activeChannelsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activeChannelsMeta);
    }
    if (data.containsKey('total_trials')) {
      context.handle(
        _totalTrialsMeta,
        totalTrials.isAcceptableOrUnknown(
          data['total_trials']!,
          _totalTrialsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalTrialsMeta);
    }
    if (data.containsKey('stimulus_duration_ms')) {
      context.handle(
        _stimulusDurationMsMeta,
        stimulusDurationMs.isAcceptableOrUnknown(
          data['stimulus_duration_ms']!,
          _stimulusDurationMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stimulusDurationMsMeta);
    }
    if (data.containsKey('isi_ms')) {
      context.handle(
        _isiMsMeta,
        isiMs.isAcceptableOrUnknown(data['isi_ms']!, _isiMsMeta),
      );
    } else if (isInserting) {
      context.missing(_isiMsMeta);
    }
    if (data.containsKey('min_accuracy')) {
      context.handle(
        _minAccuracyMeta,
        minAccuracy.isAcceptableOrUnknown(
          data['min_accuracy']!,
          _minAccuracyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minAccuracyMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('profile_name')) {
      context.handle(
        _profileNameMeta,
        profileName.isAcceptableOrUnknown(
          data['profile_name']!,
          _profileNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      n: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}n'],
      )!,
      newN: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_n'],
      )!,
      activeChannels: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_channels'],
      )!,
      totalTrials: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_trials'],
      )!,
      stimulusDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stimulus_duration_ms'],
      )!,
      isiMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}isi_ms'],
      )!,
      minAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_accuracy'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      ),
      profileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_name'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final DateTime startedAt;

  /// N value used during this session.
  final int n;

  /// Recommended next N (after adaptive adjustment, or unchanged if disabled).
  final int newN;

  /// Comma-separated `ChannelType.name` values of active channels.
  final String activeChannels;
  final int totalTrials;
  final int stimulusDurationMs;
  final int isiMs;

  /// Worst per-channel accuracy across the session (Jaeggi score).
  final double minAccuracy;

  /// Id of the training profile this session was played with
  /// (`Preset.defaultPresetId` for the built-in one). Nullable: sessions
  /// recorded before profiles existed have no value.
  final String? profileId;

  /// Snapshot of the profile's name at play time (empty for the default
  /// profile, whose display name is localized). Survives later renames or
  /// deletes of the profile.
  final String? profileName;
  const Session({
    required this.id,
    required this.startedAt,
    required this.n,
    required this.newN,
    required this.activeChannels,
    required this.totalTrials,
    required this.stimulusDurationMs,
    required this.isiMs,
    required this.minAccuracy,
    this.profileId,
    this.profileName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['n'] = Variable<int>(n);
    map['new_n'] = Variable<int>(newN);
    map['active_channels'] = Variable<String>(activeChannels);
    map['total_trials'] = Variable<int>(totalTrials);
    map['stimulus_duration_ms'] = Variable<int>(stimulusDurationMs);
    map['isi_ms'] = Variable<int>(isiMs);
    map['min_accuracy'] = Variable<double>(minAccuracy);
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<String>(profileId);
    }
    if (!nullToAbsent || profileName != null) {
      map['profile_name'] = Variable<String>(profileName);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      n: Value(n),
      newN: Value(newN),
      activeChannels: Value(activeChannels),
      totalTrials: Value(totalTrials),
      stimulusDurationMs: Value(stimulusDurationMs),
      isiMs: Value(isiMs),
      minAccuracy: Value(minAccuracy),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      profileName: profileName == null && nullToAbsent
          ? const Value.absent()
          : Value(profileName),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      n: serializer.fromJson<int>(json['n']),
      newN: serializer.fromJson<int>(json['newN']),
      activeChannels: serializer.fromJson<String>(json['activeChannels']),
      totalTrials: serializer.fromJson<int>(json['totalTrials']),
      stimulusDurationMs: serializer.fromJson<int>(json['stimulusDurationMs']),
      isiMs: serializer.fromJson<int>(json['isiMs']),
      minAccuracy: serializer.fromJson<double>(json['minAccuracy']),
      profileId: serializer.fromJson<String?>(json['profileId']),
      profileName: serializer.fromJson<String?>(json['profileName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'n': serializer.toJson<int>(n),
      'newN': serializer.toJson<int>(newN),
      'activeChannels': serializer.toJson<String>(activeChannels),
      'totalTrials': serializer.toJson<int>(totalTrials),
      'stimulusDurationMs': serializer.toJson<int>(stimulusDurationMs),
      'isiMs': serializer.toJson<int>(isiMs),
      'minAccuracy': serializer.toJson<double>(minAccuracy),
      'profileId': serializer.toJson<String?>(profileId),
      'profileName': serializer.toJson<String?>(profileName),
    };
  }

  Session copyWith({
    int? id,
    DateTime? startedAt,
    int? n,
    int? newN,
    String? activeChannels,
    int? totalTrials,
    int? stimulusDurationMs,
    int? isiMs,
    double? minAccuracy,
    Value<String?> profileId = const Value.absent(),
    Value<String?> profileName = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    n: n ?? this.n,
    newN: newN ?? this.newN,
    activeChannels: activeChannels ?? this.activeChannels,
    totalTrials: totalTrials ?? this.totalTrials,
    stimulusDurationMs: stimulusDurationMs ?? this.stimulusDurationMs,
    isiMs: isiMs ?? this.isiMs,
    minAccuracy: minAccuracy ?? this.minAccuracy,
    profileId: profileId.present ? profileId.value : this.profileId,
    profileName: profileName.present ? profileName.value : this.profileName,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      n: data.n.present ? data.n.value : this.n,
      newN: data.newN.present ? data.newN.value : this.newN,
      activeChannels: data.activeChannels.present
          ? data.activeChannels.value
          : this.activeChannels,
      totalTrials: data.totalTrials.present
          ? data.totalTrials.value
          : this.totalTrials,
      stimulusDurationMs: data.stimulusDurationMs.present
          ? data.stimulusDurationMs.value
          : this.stimulusDurationMs,
      isiMs: data.isiMs.present ? data.isiMs.value : this.isiMs,
      minAccuracy: data.minAccuracy.present
          ? data.minAccuracy.value
          : this.minAccuracy,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      profileName: data.profileName.present
          ? data.profileName.value
          : this.profileName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('n: $n, ')
          ..write('newN: $newN, ')
          ..write('activeChannels: $activeChannels, ')
          ..write('totalTrials: $totalTrials, ')
          ..write('stimulusDurationMs: $stimulusDurationMs, ')
          ..write('isiMs: $isiMs, ')
          ..write('minAccuracy: $minAccuracy, ')
          ..write('profileId: $profileId, ')
          ..write('profileName: $profileName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    n,
    newN,
    activeChannels,
    totalTrials,
    stimulusDurationMs,
    isiMs,
    minAccuracy,
    profileId,
    profileName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.n == this.n &&
          other.newN == this.newN &&
          other.activeChannels == this.activeChannels &&
          other.totalTrials == this.totalTrials &&
          other.stimulusDurationMs == this.stimulusDurationMs &&
          other.isiMs == this.isiMs &&
          other.minAccuracy == this.minAccuracy &&
          other.profileId == this.profileId &&
          other.profileName == this.profileName);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<int> n;
  final Value<int> newN;
  final Value<String> activeChannels;
  final Value<int> totalTrials;
  final Value<int> stimulusDurationMs;
  final Value<int> isiMs;
  final Value<double> minAccuracy;
  final Value<String?> profileId;
  final Value<String?> profileName;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.n = const Value.absent(),
    this.newN = const Value.absent(),
    this.activeChannels = const Value.absent(),
    this.totalTrials = const Value.absent(),
    this.stimulusDurationMs = const Value.absent(),
    this.isiMs = const Value.absent(),
    this.minAccuracy = const Value.absent(),
    this.profileId = const Value.absent(),
    this.profileName = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    required int n,
    required int newN,
    required String activeChannels,
    required int totalTrials,
    required int stimulusDurationMs,
    required int isiMs,
    required double minAccuracy,
    this.profileId = const Value.absent(),
    this.profileName = const Value.absent(),
  }) : startedAt = Value(startedAt),
       n = Value(n),
       newN = Value(newN),
       activeChannels = Value(activeChannels),
       totalTrials = Value(totalTrials),
       stimulusDurationMs = Value(stimulusDurationMs),
       isiMs = Value(isiMs),
       minAccuracy = Value(minAccuracy);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<int>? n,
    Expression<int>? newN,
    Expression<String>? activeChannels,
    Expression<int>? totalTrials,
    Expression<int>? stimulusDurationMs,
    Expression<int>? isiMs,
    Expression<double>? minAccuracy,
    Expression<String>? profileId,
    Expression<String>? profileName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (n != null) 'n': n,
      if (newN != null) 'new_n': newN,
      if (activeChannels != null) 'active_channels': activeChannels,
      if (totalTrials != null) 'total_trials': totalTrials,
      if (stimulusDurationMs != null)
        'stimulus_duration_ms': stimulusDurationMs,
      if (isiMs != null) 'isi_ms': isiMs,
      if (minAccuracy != null) 'min_accuracy': minAccuracy,
      if (profileId != null) 'profile_id': profileId,
      if (profileName != null) 'profile_name': profileName,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<int>? n,
    Value<int>? newN,
    Value<String>? activeChannels,
    Value<int>? totalTrials,
    Value<int>? stimulusDurationMs,
    Value<int>? isiMs,
    Value<double>? minAccuracy,
    Value<String?>? profileId,
    Value<String?>? profileName,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      n: n ?? this.n,
      newN: newN ?? this.newN,
      activeChannels: activeChannels ?? this.activeChannels,
      totalTrials: totalTrials ?? this.totalTrials,
      stimulusDurationMs: stimulusDurationMs ?? this.stimulusDurationMs,
      isiMs: isiMs ?? this.isiMs,
      minAccuracy: minAccuracy ?? this.minAccuracy,
      profileId: profileId ?? this.profileId,
      profileName: profileName ?? this.profileName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (n.present) {
      map['n'] = Variable<int>(n.value);
    }
    if (newN.present) {
      map['new_n'] = Variable<int>(newN.value);
    }
    if (activeChannels.present) {
      map['active_channels'] = Variable<String>(activeChannels.value);
    }
    if (totalTrials.present) {
      map['total_trials'] = Variable<int>(totalTrials.value);
    }
    if (stimulusDurationMs.present) {
      map['stimulus_duration_ms'] = Variable<int>(stimulusDurationMs.value);
    }
    if (isiMs.present) {
      map['isi_ms'] = Variable<int>(isiMs.value);
    }
    if (minAccuracy.present) {
      map['min_accuracy'] = Variable<double>(minAccuracy.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (profileName.present) {
      map['profile_name'] = Variable<String>(profileName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('n: $n, ')
          ..write('newN: $newN, ')
          ..write('activeChannels: $activeChannels, ')
          ..write('totalTrials: $totalTrials, ')
          ..write('stimulusDurationMs: $stimulusDurationMs, ')
          ..write('isiMs: $isiMs, ')
          ..write('minAccuracy: $minAccuracy, ')
          ..write('profileId: $profileId, ')
          ..write('profileName: $profileName')
          ..write(')'))
        .toString();
  }
}

class $ChannelScoresTable extends ChannelScores
    with TableInfo<$ChannelScoresTable, ChannelScore> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChannelScoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _channelMeta = const VerificationMeta(
    'channel',
  );
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
    'channel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hitsMeta = const VerificationMeta('hits');
  @override
  late final GeneratedColumn<int> hits = GeneratedColumn<int>(
    'hits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _missesMeta = const VerificationMeta('misses');
  @override
  late final GeneratedColumn<int> misses = GeneratedColumn<int>(
    'misses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _falseAlarmsMeta = const VerificationMeta(
    'falseAlarms',
  );
  @override
  late final GeneratedColumn<int> falseAlarms = GeneratedColumn<int>(
    'false_alarms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctRejectionsMeta = const VerificationMeta(
    'correctRejections',
  );
  @override
  late final GeneratedColumn<int> correctRejections = GeneratedColumn<int>(
    'correct_rejections',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dPrimeMeta = const VerificationMeta('dPrime');
  @override
  late final GeneratedColumn<double> dPrime = GeneratedColumn<double>(
    'd_prime',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    channel,
    hits,
    misses,
    falseAlarms,
    correctRejections,
    accuracy,
    dPrime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'channel_scores';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChannelScore> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('channel')) {
      context.handle(
        _channelMeta,
        channel.isAcceptableOrUnknown(data['channel']!, _channelMeta),
      );
    } else if (isInserting) {
      context.missing(_channelMeta);
    }
    if (data.containsKey('hits')) {
      context.handle(
        _hitsMeta,
        hits.isAcceptableOrUnknown(data['hits']!, _hitsMeta),
      );
    } else if (isInserting) {
      context.missing(_hitsMeta);
    }
    if (data.containsKey('misses')) {
      context.handle(
        _missesMeta,
        misses.isAcceptableOrUnknown(data['misses']!, _missesMeta),
      );
    } else if (isInserting) {
      context.missing(_missesMeta);
    }
    if (data.containsKey('false_alarms')) {
      context.handle(
        _falseAlarmsMeta,
        falseAlarms.isAcceptableOrUnknown(
          data['false_alarms']!,
          _falseAlarmsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_falseAlarmsMeta);
    }
    if (data.containsKey('correct_rejections')) {
      context.handle(
        _correctRejectionsMeta,
        correctRejections.isAcceptableOrUnknown(
          data['correct_rejections']!,
          _correctRejectionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctRejectionsMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    } else if (isInserting) {
      context.missing(_accuracyMeta);
    }
    if (data.containsKey('d_prime')) {
      context.handle(
        _dPrimeMeta,
        dPrime.isAcceptableOrUnknown(data['d_prime']!, _dPrimeMeta),
      );
    } else if (isInserting) {
      context.missing(_dPrimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChannelScore map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChannelScore(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      channel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel'],
      )!,
      hits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hits'],
      )!,
      misses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}misses'],
      )!,
      falseAlarms: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}false_alarms'],
      )!,
      correctRejections: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_rejections'],
      )!,
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      )!,
      dPrime: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}d_prime'],
      )!,
    );
  }

  @override
  $ChannelScoresTable createAlias(String alias) {
    return $ChannelScoresTable(attachedDatabase, alias);
  }
}

class ChannelScore extends DataClass implements Insertable<ChannelScore> {
  final int id;
  final int sessionId;

  /// `ChannelType.name`.
  final String channel;
  final int hits;
  final int misses;
  final int falseAlarms;
  final int correctRejections;
  final double accuracy;
  final double dPrime;
  const ChannelScore({
    required this.id,
    required this.sessionId,
    required this.channel,
    required this.hits,
    required this.misses,
    required this.falseAlarms,
    required this.correctRejections,
    required this.accuracy,
    required this.dPrime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['channel'] = Variable<String>(channel);
    map['hits'] = Variable<int>(hits);
    map['misses'] = Variable<int>(misses);
    map['false_alarms'] = Variable<int>(falseAlarms);
    map['correct_rejections'] = Variable<int>(correctRejections);
    map['accuracy'] = Variable<double>(accuracy);
    map['d_prime'] = Variable<double>(dPrime);
    return map;
  }

  ChannelScoresCompanion toCompanion(bool nullToAbsent) {
    return ChannelScoresCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      channel: Value(channel),
      hits: Value(hits),
      misses: Value(misses),
      falseAlarms: Value(falseAlarms),
      correctRejections: Value(correctRejections),
      accuracy: Value(accuracy),
      dPrime: Value(dPrime),
    );
  }

  factory ChannelScore.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChannelScore(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      channel: serializer.fromJson<String>(json['channel']),
      hits: serializer.fromJson<int>(json['hits']),
      misses: serializer.fromJson<int>(json['misses']),
      falseAlarms: serializer.fromJson<int>(json['falseAlarms']),
      correctRejections: serializer.fromJson<int>(json['correctRejections']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      dPrime: serializer.fromJson<double>(json['dPrime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'channel': serializer.toJson<String>(channel),
      'hits': serializer.toJson<int>(hits),
      'misses': serializer.toJson<int>(misses),
      'falseAlarms': serializer.toJson<int>(falseAlarms),
      'correctRejections': serializer.toJson<int>(correctRejections),
      'accuracy': serializer.toJson<double>(accuracy),
      'dPrime': serializer.toJson<double>(dPrime),
    };
  }

  ChannelScore copyWith({
    int? id,
    int? sessionId,
    String? channel,
    int? hits,
    int? misses,
    int? falseAlarms,
    int? correctRejections,
    double? accuracy,
    double? dPrime,
  }) => ChannelScore(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    channel: channel ?? this.channel,
    hits: hits ?? this.hits,
    misses: misses ?? this.misses,
    falseAlarms: falseAlarms ?? this.falseAlarms,
    correctRejections: correctRejections ?? this.correctRejections,
    accuracy: accuracy ?? this.accuracy,
    dPrime: dPrime ?? this.dPrime,
  );
  ChannelScore copyWithCompanion(ChannelScoresCompanion data) {
    return ChannelScore(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      channel: data.channel.present ? data.channel.value : this.channel,
      hits: data.hits.present ? data.hits.value : this.hits,
      misses: data.misses.present ? data.misses.value : this.misses,
      falseAlarms: data.falseAlarms.present
          ? data.falseAlarms.value
          : this.falseAlarms,
      correctRejections: data.correctRejections.present
          ? data.correctRejections.value
          : this.correctRejections,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      dPrime: data.dPrime.present ? data.dPrime.value : this.dPrime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChannelScore(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('channel: $channel, ')
          ..write('hits: $hits, ')
          ..write('misses: $misses, ')
          ..write('falseAlarms: $falseAlarms, ')
          ..write('correctRejections: $correctRejections, ')
          ..write('accuracy: $accuracy, ')
          ..write('dPrime: $dPrime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    channel,
    hits,
    misses,
    falseAlarms,
    correctRejections,
    accuracy,
    dPrime,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChannelScore &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.channel == this.channel &&
          other.hits == this.hits &&
          other.misses == this.misses &&
          other.falseAlarms == this.falseAlarms &&
          other.correctRejections == this.correctRejections &&
          other.accuracy == this.accuracy &&
          other.dPrime == this.dPrime);
}

class ChannelScoresCompanion extends UpdateCompanion<ChannelScore> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> channel;
  final Value<int> hits;
  final Value<int> misses;
  final Value<int> falseAlarms;
  final Value<int> correctRejections;
  final Value<double> accuracy;
  final Value<double> dPrime;
  const ChannelScoresCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.channel = const Value.absent(),
    this.hits = const Value.absent(),
    this.misses = const Value.absent(),
    this.falseAlarms = const Value.absent(),
    this.correctRejections = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.dPrime = const Value.absent(),
  });
  ChannelScoresCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String channel,
    required int hits,
    required int misses,
    required int falseAlarms,
    required int correctRejections,
    required double accuracy,
    required double dPrime,
  }) : sessionId = Value(sessionId),
       channel = Value(channel),
       hits = Value(hits),
       misses = Value(misses),
       falseAlarms = Value(falseAlarms),
       correctRejections = Value(correctRejections),
       accuracy = Value(accuracy),
       dPrime = Value(dPrime);
  static Insertable<ChannelScore> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? channel,
    Expression<int>? hits,
    Expression<int>? misses,
    Expression<int>? falseAlarms,
    Expression<int>? correctRejections,
    Expression<double>? accuracy,
    Expression<double>? dPrime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (channel != null) 'channel': channel,
      if (hits != null) 'hits': hits,
      if (misses != null) 'misses': misses,
      if (falseAlarms != null) 'false_alarms': falseAlarms,
      if (correctRejections != null) 'correct_rejections': correctRejections,
      if (accuracy != null) 'accuracy': accuracy,
      if (dPrime != null) 'd_prime': dPrime,
    });
  }

  ChannelScoresCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? channel,
    Value<int>? hits,
    Value<int>? misses,
    Value<int>? falseAlarms,
    Value<int>? correctRejections,
    Value<double>? accuracy,
    Value<double>? dPrime,
  }) {
    return ChannelScoresCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      channel: channel ?? this.channel,
      hits: hits ?? this.hits,
      misses: misses ?? this.misses,
      falseAlarms: falseAlarms ?? this.falseAlarms,
      correctRejections: correctRejections ?? this.correctRejections,
      accuracy: accuracy ?? this.accuracy,
      dPrime: dPrime ?? this.dPrime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (hits.present) {
      map['hits'] = Variable<int>(hits.value);
    }
    if (misses.present) {
      map['misses'] = Variable<int>(misses.value);
    }
    if (falseAlarms.present) {
      map['false_alarms'] = Variable<int>(falseAlarms.value);
    }
    if (correctRejections.present) {
      map['correct_rejections'] = Variable<int>(correctRejections.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (dPrime.present) {
      map['d_prime'] = Variable<double>(dPrime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChannelScoresCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('channel: $channel, ')
          ..write('hits: $hits, ')
          ..write('misses: $misses, ')
          ..write('falseAlarms: $falseAlarms, ')
          ..write('correctRejections: $correctRejections, ')
          ..write('accuracy: $accuracy, ')
          ..write('dPrime: $dPrime')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $ChannelScoresTable channelScores = $ChannelScoresTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [sessions, channelScores];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('channel_scores', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required DateTime startedAt,
      required int n,
      required int newN,
      required String activeChannels,
      required int totalTrials,
      required int stimulusDurationMs,
      required int isiMs,
      required double minAccuracy,
      Value<String?> profileId,
      Value<String?> profileName,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<DateTime> startedAt,
      Value<int> n,
      Value<int> newN,
      Value<String> activeChannels,
      Value<int> totalTrials,
      Value<int> stimulusDurationMs,
      Value<int> isiMs,
      Value<double> minAccuracy,
      Value<String?> profileId,
      Value<String?> profileName,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChannelScoresTable, List<ChannelScore>>
  _channelScoresRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.channelScores,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.channelScores.sessionId),
  );

  $$ChannelScoresTableProcessedTableManager get channelScoresRefs {
    final manager = $$ChannelScoresTableTableManager(
      $_db,
      $_db.channelScores,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_channelScoresRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get n => $composableBuilder(
    column: $table.n,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newN => $composableBuilder(
    column: $table.newN,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeChannels => $composableBuilder(
    column: $table.activeChannels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalTrials => $composableBuilder(
    column: $table.totalTrials,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stimulusDurationMs => $composableBuilder(
    column: $table.stimulusDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isiMs => $composableBuilder(
    column: $table.isiMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minAccuracy => $composableBuilder(
    column: $table.minAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileName => $composableBuilder(
    column: $table.profileName,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> channelScoresRefs(
    Expression<bool> Function($$ChannelScoresTableFilterComposer f) f,
  ) {
    final $$ChannelScoresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.channelScores,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChannelScoresTableFilterComposer(
            $db: $db,
            $table: $db.channelScores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get n => $composableBuilder(
    column: $table.n,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newN => $composableBuilder(
    column: $table.newN,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeChannels => $composableBuilder(
    column: $table.activeChannels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalTrials => $composableBuilder(
    column: $table.totalTrials,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stimulusDurationMs => $composableBuilder(
    column: $table.stimulusDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isiMs => $composableBuilder(
    column: $table.isiMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minAccuracy => $composableBuilder(
    column: $table.minAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileName => $composableBuilder(
    column: $table.profileName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get n =>
      $composableBuilder(column: $table.n, builder: (column) => column);

  GeneratedColumn<int> get newN =>
      $composableBuilder(column: $table.newN, builder: (column) => column);

  GeneratedColumn<String> get activeChannels => $composableBuilder(
    column: $table.activeChannels,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalTrials => $composableBuilder(
    column: $table.totalTrials,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stimulusDurationMs => $composableBuilder(
    column: $table.stimulusDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isiMs =>
      $composableBuilder(column: $table.isiMs, builder: (column) => column);

  GeneratedColumn<double> get minAccuracy => $composableBuilder(
    column: $table.minAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get profileName => $composableBuilder(
    column: $table.profileName,
    builder: (column) => column,
  );

  Expression<T> channelScoresRefs<T extends Object>(
    Expression<T> Function($$ChannelScoresTableAnnotationComposer a) f,
  ) {
    final $$ChannelScoresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.channelScores,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChannelScoresTableAnnotationComposer(
            $db: $db,
            $table: $db.channelScores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({bool channelScoresRefs})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> n = const Value.absent(),
                Value<int> newN = const Value.absent(),
                Value<String> activeChannels = const Value.absent(),
                Value<int> totalTrials = const Value.absent(),
                Value<int> stimulusDurationMs = const Value.absent(),
                Value<int> isiMs = const Value.absent(),
                Value<double> minAccuracy = const Value.absent(),
                Value<String?> profileId = const Value.absent(),
                Value<String?> profileName = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                startedAt: startedAt,
                n: n,
                newN: newN,
                activeChannels: activeChannels,
                totalTrials: totalTrials,
                stimulusDurationMs: stimulusDurationMs,
                isiMs: isiMs,
                minAccuracy: minAccuracy,
                profileId: profileId,
                profileName: profileName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                required int n,
                required int newN,
                required String activeChannels,
                required int totalTrials,
                required int stimulusDurationMs,
                required int isiMs,
                required double minAccuracy,
                Value<String?> profileId = const Value.absent(),
                Value<String?> profileName = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                startedAt: startedAt,
                n: n,
                newN: newN,
                activeChannels: activeChannels,
                totalTrials: totalTrials,
                stimulusDurationMs: stimulusDurationMs,
                isiMs: isiMs,
                minAccuracy: minAccuracy,
                profileId: profileId,
                profileName: profileName,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({channelScoresRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (channelScoresRefs) db.channelScores,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (channelScoresRefs)
                    await $_getPrefetchedData<
                      Session,
                      $SessionsTable,
                      ChannelScore
                    >(
                      currentTable: table,
                      referencedTable: $$SessionsTableReferences
                          ._channelScoresRefsTable(db),
                      managerFromTypedResult: (p0) => $$SessionsTableReferences(
                        db,
                        table,
                        p0,
                      ).channelScoresRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({bool channelScoresRefs})
    >;
typedef $$ChannelScoresTableCreateCompanionBuilder =
    ChannelScoresCompanion Function({
      Value<int> id,
      required int sessionId,
      required String channel,
      required int hits,
      required int misses,
      required int falseAlarms,
      required int correctRejections,
      required double accuracy,
      required double dPrime,
    });
typedef $$ChannelScoresTableUpdateCompanionBuilder =
    ChannelScoresCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> channel,
      Value<int> hits,
      Value<int> misses,
      Value<int> falseAlarms,
      Value<int> correctRejections,
      Value<double> accuracy,
      Value<double> dPrime,
    });

final class $$ChannelScoresTableReferences
    extends BaseReferences<_$AppDatabase, $ChannelScoresTable, ChannelScore> {
  $$ChannelScoresTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias(
        $_aliasNameGenerator(db.channelScores.sessionId, db.sessions.id),
      );

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChannelScoresTableFilterComposer
    extends Composer<_$AppDatabase, $ChannelScoresTable> {
  $$ChannelScoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hits => $composableBuilder(
    column: $table.hits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get misses => $composableBuilder(
    column: $table.misses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get falseAlarms => $composableBuilder(
    column: $table.falseAlarms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctRejections => $composableBuilder(
    column: $table.correctRejections,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dPrime => $composableBuilder(
    column: $table.dPrime,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChannelScoresTableOrderingComposer
    extends Composer<_$AppDatabase, $ChannelScoresTable> {
  $$ChannelScoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hits => $composableBuilder(
    column: $table.hits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get misses => $composableBuilder(
    column: $table.misses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get falseAlarms => $composableBuilder(
    column: $table.falseAlarms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctRejections => $composableBuilder(
    column: $table.correctRejections,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dPrime => $composableBuilder(
    column: $table.dPrime,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChannelScoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChannelScoresTable> {
  $$ChannelScoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<int> get hits =>
      $composableBuilder(column: $table.hits, builder: (column) => column);

  GeneratedColumn<int> get misses =>
      $composableBuilder(column: $table.misses, builder: (column) => column);

  GeneratedColumn<int> get falseAlarms => $composableBuilder(
    column: $table.falseAlarms,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctRejections => $composableBuilder(
    column: $table.correctRejections,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<double> get dPrime =>
      $composableBuilder(column: $table.dPrime, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChannelScoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChannelScoresTable,
          ChannelScore,
          $$ChannelScoresTableFilterComposer,
          $$ChannelScoresTableOrderingComposer,
          $$ChannelScoresTableAnnotationComposer,
          $$ChannelScoresTableCreateCompanionBuilder,
          $$ChannelScoresTableUpdateCompanionBuilder,
          (ChannelScore, $$ChannelScoresTableReferences),
          ChannelScore,
          PrefetchHooks Function({bool sessionId})
        > {
  $$ChannelScoresTableTableManager(_$AppDatabase db, $ChannelScoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChannelScoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChannelScoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChannelScoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> channel = const Value.absent(),
                Value<int> hits = const Value.absent(),
                Value<int> misses = const Value.absent(),
                Value<int> falseAlarms = const Value.absent(),
                Value<int> correctRejections = const Value.absent(),
                Value<double> accuracy = const Value.absent(),
                Value<double> dPrime = const Value.absent(),
              }) => ChannelScoresCompanion(
                id: id,
                sessionId: sessionId,
                channel: channel,
                hits: hits,
                misses: misses,
                falseAlarms: falseAlarms,
                correctRejections: correctRejections,
                accuracy: accuracy,
                dPrime: dPrime,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String channel,
                required int hits,
                required int misses,
                required int falseAlarms,
                required int correctRejections,
                required double accuracy,
                required double dPrime,
              }) => ChannelScoresCompanion.insert(
                id: id,
                sessionId: sessionId,
                channel: channel,
                hits: hits,
                misses: misses,
                falseAlarms: falseAlarms,
                correctRejections: correctRejections,
                accuracy: accuracy,
                dPrime: dPrime,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChannelScoresTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$ChannelScoresTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$ChannelScoresTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChannelScoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChannelScoresTable,
      ChannelScore,
      $$ChannelScoresTableFilterComposer,
      $$ChannelScoresTableOrderingComposer,
      $$ChannelScoresTableAnnotationComposer,
      $$ChannelScoresTableCreateCompanionBuilder,
      $$ChannelScoresTableUpdateCompanionBuilder,
      (ChannelScore, $$ChannelScoresTableReferences),
      ChannelScore,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$ChannelScoresTableTableManager get channelScores =>
      $$ChannelScoresTableTableManager(_db, _db.channelScores);
}
