// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recordings.dart';

// ignore_for_file: type=lint
class $RecordingsTable extends Recordings
    with TableInfo<$RecordingsTable, Recording> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecordingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _meetingIdMeta = const VerificationMeta(
    'meetingId',
  );
  @override
  late final GeneratedColumn<String> meetingId = GeneratedColumn<String>(
    'meeting_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isTranscriptActivatedMeta =
      const VerificationMeta('isTranscriptActivated');
  @override
  late final GeneratedColumn<bool> isTranscriptActivated =
      GeneratedColumn<bool>(
        'is_transcript_activated',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_transcript_activated" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _isSummaryActivatedMeta =
      const VerificationMeta('isSummaryActivated');
  @override
  late final GeneratedColumn<bool> isSummaryActivated = GeneratedColumn<bool>(
    'is_summary_activated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_summary_activated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    meetingId,
    title,
    status,
    filePath,
    duration,
    recordedAt,
    isTranscriptActivated,
    isSummaryActivated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recordings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recording> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('meeting_id')) {
      context.handle(
        _meetingIdMeta,
        meetingId.isAcceptableOrUnknown(data['meeting_id']!, _meetingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_meetingIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('is_transcript_activated')) {
      context.handle(
        _isTranscriptActivatedMeta,
        isTranscriptActivated.isAcceptableOrUnknown(
          data['is_transcript_activated']!,
          _isTranscriptActivatedMeta,
        ),
      );
    }
    if (data.containsKey('is_summary_activated')) {
      context.handle(
        _isSummaryActivatedMeta,
        isSummaryActivated.isAcceptableOrUnknown(
          data['is_summary_activated']!,
          _isSummaryActivatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {meetingId},
  ];
  @override
  Recording map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recording(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      meetingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meeting_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      isTranscriptActivated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_transcript_activated'],
      )!,
      isSummaryActivated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_summary_activated'],
      )!,
    );
  }

  @override
  $RecordingsTable createAlias(String alias) {
    return $RecordingsTable(attachedDatabase, alias);
  }
}

class Recording extends DataClass implements Insertable<Recording> {
  final int id;
  final String meetingId;
  final String title;
  final String status;
  final String filePath;
  final int duration;
  final DateTime recordedAt;
  final bool isTranscriptActivated;
  final bool isSummaryActivated;
  const Recording({
    required this.id,
    required this.meetingId,
    required this.title,
    required this.status,
    required this.filePath,
    required this.duration,
    required this.recordedAt,
    required this.isTranscriptActivated,
    required this.isSummaryActivated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['meeting_id'] = Variable<String>(meetingId);
    map['title'] = Variable<String>(title);
    map['status'] = Variable<String>(status);
    map['file_path'] = Variable<String>(filePath);
    map['duration'] = Variable<int>(duration);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['is_transcript_activated'] = Variable<bool>(isTranscriptActivated);
    map['is_summary_activated'] = Variable<bool>(isSummaryActivated);
    return map;
  }

  RecordingsCompanion toCompanion(bool nullToAbsent) {
    return RecordingsCompanion(
      id: Value(id),
      meetingId: Value(meetingId),
      title: Value(title),
      status: Value(status),
      filePath: Value(filePath),
      duration: Value(duration),
      recordedAt: Value(recordedAt),
      isTranscriptActivated: Value(isTranscriptActivated),
      isSummaryActivated: Value(isSummaryActivated),
    );
  }

  factory Recording.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recording(
      id: serializer.fromJson<int>(json['id']),
      meetingId: serializer.fromJson<String>(json['meetingId']),
      title: serializer.fromJson<String>(json['title']),
      status: serializer.fromJson<String>(json['status']),
      filePath: serializer.fromJson<String>(json['filePath']),
      duration: serializer.fromJson<int>(json['duration']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      isTranscriptActivated: serializer.fromJson<bool>(
        json['isTranscriptActivated'],
      ),
      isSummaryActivated: serializer.fromJson<bool>(json['isSummaryActivated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'meetingId': serializer.toJson<String>(meetingId),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<String>(status),
      'filePath': serializer.toJson<String>(filePath),
      'duration': serializer.toJson<int>(duration),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'isTranscriptActivated': serializer.toJson<bool>(isTranscriptActivated),
      'isSummaryActivated': serializer.toJson<bool>(isSummaryActivated),
    };
  }

  Recording copyWith({
    int? id,
    String? meetingId,
    String? title,
    String? status,
    String? filePath,
    int? duration,
    DateTime? recordedAt,
    bool? isTranscriptActivated,
    bool? isSummaryActivated,
  }) => Recording(
    id: id ?? this.id,
    meetingId: meetingId ?? this.meetingId,
    title: title ?? this.title,
    status: status ?? this.status,
    filePath: filePath ?? this.filePath,
    duration: duration ?? this.duration,
    recordedAt: recordedAt ?? this.recordedAt,
    isTranscriptActivated: isTranscriptActivated ?? this.isTranscriptActivated,
    isSummaryActivated: isSummaryActivated ?? this.isSummaryActivated,
  );
  Recording copyWithCompanion(RecordingsCompanion data) {
    return Recording(
      id: data.id.present ? data.id.value : this.id,
      meetingId: data.meetingId.present ? data.meetingId.value : this.meetingId,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      duration: data.duration.present ? data.duration.value : this.duration,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      isTranscriptActivated: data.isTranscriptActivated.present
          ? data.isTranscriptActivated.value
          : this.isTranscriptActivated,
      isSummaryActivated: data.isSummaryActivated.present
          ? data.isSummaryActivated.value
          : this.isSummaryActivated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recording(')
          ..write('id: $id, ')
          ..write('meetingId: $meetingId, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('filePath: $filePath, ')
          ..write('duration: $duration, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('isTranscriptActivated: $isTranscriptActivated, ')
          ..write('isSummaryActivated: $isSummaryActivated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    meetingId,
    title,
    status,
    filePath,
    duration,
    recordedAt,
    isTranscriptActivated,
    isSummaryActivated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recording &&
          other.id == this.id &&
          other.meetingId == this.meetingId &&
          other.title == this.title &&
          other.status == this.status &&
          other.filePath == this.filePath &&
          other.duration == this.duration &&
          other.recordedAt == this.recordedAt &&
          other.isTranscriptActivated == this.isTranscriptActivated &&
          other.isSummaryActivated == this.isSummaryActivated);
}

class RecordingsCompanion extends UpdateCompanion<Recording> {
  final Value<int> id;
  final Value<String> meetingId;
  final Value<String> title;
  final Value<String> status;
  final Value<String> filePath;
  final Value<int> duration;
  final Value<DateTime> recordedAt;
  final Value<bool> isTranscriptActivated;
  final Value<bool> isSummaryActivated;
  const RecordingsCompanion({
    this.id = const Value.absent(),
    this.meetingId = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.filePath = const Value.absent(),
    this.duration = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.isTranscriptActivated = const Value.absent(),
    this.isSummaryActivated = const Value.absent(),
  });
  RecordingsCompanion.insert({
    this.id = const Value.absent(),
    required String meetingId,
    required String title,
    required String status,
    required String filePath,
    required int duration,
    required DateTime recordedAt,
    this.isTranscriptActivated = const Value.absent(),
    this.isSummaryActivated = const Value.absent(),
  }) : meetingId = Value(meetingId),
       title = Value(title),
       status = Value(status),
       filePath = Value(filePath),
       duration = Value(duration),
       recordedAt = Value(recordedAt);
  static Insertable<Recording> custom({
    Expression<int>? id,
    Expression<String>? meetingId,
    Expression<String>? title,
    Expression<String>? status,
    Expression<String>? filePath,
    Expression<int>? duration,
    Expression<DateTime>? recordedAt,
    Expression<bool>? isTranscriptActivated,
    Expression<bool>? isSummaryActivated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (meetingId != null) 'meeting_id': meetingId,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (filePath != null) 'file_path': filePath,
      if (duration != null) 'duration': duration,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (isTranscriptActivated != null)
        'is_transcript_activated': isTranscriptActivated,
      if (isSummaryActivated != null)
        'is_summary_activated': isSummaryActivated,
    });
  }

  RecordingsCompanion copyWith({
    Value<int>? id,
    Value<String>? meetingId,
    Value<String>? title,
    Value<String>? status,
    Value<String>? filePath,
    Value<int>? duration,
    Value<DateTime>? recordedAt,
    Value<bool>? isTranscriptActivated,
    Value<bool>? isSummaryActivated,
  }) {
    return RecordingsCompanion(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      title: title ?? this.title,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      recordedAt: recordedAt ?? this.recordedAt,
      isTranscriptActivated:
          isTranscriptActivated ?? this.isTranscriptActivated,
      isSummaryActivated: isSummaryActivated ?? this.isSummaryActivated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (meetingId.present) {
      map['meeting_id'] = Variable<String>(meetingId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (isTranscriptActivated.present) {
      map['is_transcript_activated'] = Variable<bool>(
        isTranscriptActivated.value,
      );
    }
    if (isSummaryActivated.present) {
      map['is_summary_activated'] = Variable<bool>(isSummaryActivated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecordingsCompanion(')
          ..write('id: $id, ')
          ..write('meetingId: $meetingId, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('filePath: $filePath, ')
          ..write('duration: $duration, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('isTranscriptActivated: $isTranscriptActivated, ')
          ..write('isSummaryActivated: $isSummaryActivated')
          ..write(')'))
        .toString();
  }
}

abstract class _$RecordingDatabase extends GeneratedDatabase {
  _$RecordingDatabase(QueryExecutor e) : super(e);
  $RecordingDatabaseManager get managers => $RecordingDatabaseManager(this);
  late final $RecordingsTable recordings = $RecordingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [recordings];
}

typedef $$RecordingsTableCreateCompanionBuilder =
    RecordingsCompanion Function({
      Value<int> id,
      required String meetingId,
      required String title,
      required String status,
      required String filePath,
      required int duration,
      required DateTime recordedAt,
      Value<bool> isTranscriptActivated,
      Value<bool> isSummaryActivated,
    });
typedef $$RecordingsTableUpdateCompanionBuilder =
    RecordingsCompanion Function({
      Value<int> id,
      Value<String> meetingId,
      Value<String> title,
      Value<String> status,
      Value<String> filePath,
      Value<int> duration,
      Value<DateTime> recordedAt,
      Value<bool> isTranscriptActivated,
      Value<bool> isSummaryActivated,
    });

class $$RecordingsTableFilterComposer
    extends Composer<_$RecordingDatabase, $RecordingsTable> {
  $$RecordingsTableFilterComposer({
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

  ColumnFilters<String> get meetingId => $composableBuilder(
    column: $table.meetingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTranscriptActivated => $composableBuilder(
    column: $table.isTranscriptActivated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSummaryActivated => $composableBuilder(
    column: $table.isSummaryActivated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecordingsTableOrderingComposer
    extends Composer<_$RecordingDatabase, $RecordingsTable> {
  $$RecordingsTableOrderingComposer({
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

  ColumnOrderings<String> get meetingId => $composableBuilder(
    column: $table.meetingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTranscriptActivated => $composableBuilder(
    column: $table.isTranscriptActivated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSummaryActivated => $composableBuilder(
    column: $table.isSummaryActivated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecordingsTableAnnotationComposer
    extends Composer<_$RecordingDatabase, $RecordingsTable> {
  $$RecordingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get meetingId =>
      $composableBuilder(column: $table.meetingId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTranscriptActivated => $composableBuilder(
    column: $table.isTranscriptActivated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSummaryActivated => $composableBuilder(
    column: $table.isSummaryActivated,
    builder: (column) => column,
  );
}

class $$RecordingsTableTableManager
    extends
        RootTableManager<
          _$RecordingDatabase,
          $RecordingsTable,
          Recording,
          $$RecordingsTableFilterComposer,
          $$RecordingsTableOrderingComposer,
          $$RecordingsTableAnnotationComposer,
          $$RecordingsTableCreateCompanionBuilder,
          $$RecordingsTableUpdateCompanionBuilder,
          (
            Recording,
            BaseReferences<_$RecordingDatabase, $RecordingsTable, Recording>,
          ),
          Recording,
          PrefetchHooks Function()
        > {
  $$RecordingsTableTableManager(_$RecordingDatabase db, $RecordingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecordingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecordingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecordingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> meetingId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<bool> isTranscriptActivated = const Value.absent(),
                Value<bool> isSummaryActivated = const Value.absent(),
              }) => RecordingsCompanion(
                id: id,
                meetingId: meetingId,
                title: title,
                status: status,
                filePath: filePath,
                duration: duration,
                recordedAt: recordedAt,
                isTranscriptActivated: isTranscriptActivated,
                isSummaryActivated: isSummaryActivated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String meetingId,
                required String title,
                required String status,
                required String filePath,
                required int duration,
                required DateTime recordedAt,
                Value<bool> isTranscriptActivated = const Value.absent(),
                Value<bool> isSummaryActivated = const Value.absent(),
              }) => RecordingsCompanion.insert(
                id: id,
                meetingId: meetingId,
                title: title,
                status: status,
                filePath: filePath,
                duration: duration,
                recordedAt: recordedAt,
                isTranscriptActivated: isTranscriptActivated,
                isSummaryActivated: isSummaryActivated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecordingsTableProcessedTableManager =
    ProcessedTableManager<
      _$RecordingDatabase,
      $RecordingsTable,
      Recording,
      $$RecordingsTableFilterComposer,
      $$RecordingsTableOrderingComposer,
      $$RecordingsTableAnnotationComposer,
      $$RecordingsTableCreateCompanionBuilder,
      $$RecordingsTableUpdateCompanionBuilder,
      (
        Recording,
        BaseReferences<_$RecordingDatabase, $RecordingsTable, Recording>,
      ),
      Recording,
      PrefetchHooks Function()
    >;

class $RecordingDatabaseManager {
  final _$RecordingDatabase _db;
  $RecordingDatabaseManager(this._db);
  $$RecordingsTableTableManager get recordings =>
      $$RecordingsTableTableManager(_db, _db.recordings);
}
