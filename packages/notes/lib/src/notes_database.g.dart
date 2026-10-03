// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_database.dart';

// ignore_for_file: type=lint
class $NoteRecordsTable extends NoteRecords
    with TableInfo<$NoteRecordsTable, StoredNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, content, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NoteRecordsTable createAlias(String alias) {
    return $NoteRecordsTable(attachedDatabase, alias);
  }
}

class StoredNote extends DataClass implements Insertable<StoredNote> {
  final int id;
  final String content;
  final DateTime createdAt;
  const StoredNote({
    required this.id,
    required this.content,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NoteRecordsCompanion toCompanion(bool nullToAbsent) {
    return NoteRecordsCompanion(
      id: Value(id),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory StoredNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredNote(
      id: serializer.fromJson<int>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StoredNote copyWith({int? id, String? content, DateTime? createdAt}) =>
      StoredNote(
        id: id ?? this.id,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
      );
  StoredNote copyWithCompanion(NoteRecordsCompanion data) {
    return StoredNote(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredNote(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredNote &&
          other.id == this.id &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class NoteRecordsCompanion extends UpdateCompanion<StoredNote> {
  final Value<int> id;
  final Value<String> content;
  final Value<DateTime> createdAt;
  const NoteRecordsCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NoteRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String content,
    required DateTime createdAt,
  }) : content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<StoredNote> custom({
    Expression<int>? id,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NoteRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? content,
    Value<DateTime>? createdAt,
  }) {
    return NoteRecordsCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteRecordsCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$NotesDatabase extends GeneratedDatabase {
  _$NotesDatabase(QueryExecutor e) : super(e);
  $NotesDatabaseManager get managers => $NotesDatabaseManager(this);
  late final $NoteRecordsTable noteRecords = $NoteRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [noteRecords];
}

typedef $$NoteRecordsTableCreateCompanionBuilder =
    NoteRecordsCompanion Function({
      Value<int> id,
      required String content,
      required DateTime createdAt,
    });
typedef $$NoteRecordsTableUpdateCompanionBuilder =
    NoteRecordsCompanion Function({
      Value<int> id,
      Value<String> content,
      Value<DateTime> createdAt,
    });

class $$NoteRecordsTableFilterComposer
    extends Composer<_$NotesDatabase, $NoteRecordsTable> {
  $$NoteRecordsTableFilterComposer({
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

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NoteRecordsTableOrderingComposer
    extends Composer<_$NotesDatabase, $NoteRecordsTable> {
  $$NoteRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NoteRecordsTableAnnotationComposer
    extends Composer<_$NotesDatabase, $NoteRecordsTable> {
  $$NoteRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NoteRecordsTableTableManager
    extends
        RootTableManager<
          _$NotesDatabase,
          $NoteRecordsTable,
          StoredNote,
          $$NoteRecordsTableFilterComposer,
          $$NoteRecordsTableOrderingComposer,
          $$NoteRecordsTableAnnotationComposer,
          $$NoteRecordsTableCreateCompanionBuilder,
          $$NoteRecordsTableUpdateCompanionBuilder,
          (
            StoredNote,
            BaseReferences<_$NotesDatabase, $NoteRecordsTable, StoredNote>,
          ),
          StoredNote,
          PrefetchHooks Function()
        > {
  $$NoteRecordsTableTableManager(_$NotesDatabase db, $NoteRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => NoteRecordsCompanion(
                id: id,
                content: content,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String content,
                required DateTime createdAt,
              }) => NoteRecordsCompanion.insert(
                id: id,
                content: content,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NoteRecordsTable, StoredNote>(table),
                  BaseReferences<
                    _$NotesDatabase,
                    $NoteRecordsTable,
                    StoredNote
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NoteRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$NotesDatabase,
      $NoteRecordsTable,
      StoredNote,
      $$NoteRecordsTableFilterComposer,
      $$NoteRecordsTableOrderingComposer,
      $$NoteRecordsTableAnnotationComposer,
      $$NoteRecordsTableCreateCompanionBuilder,
      $$NoteRecordsTableUpdateCompanionBuilder,
      (
        StoredNote,
        BaseReferences<_$NotesDatabase, $NoteRecordsTable, StoredNote>,
      ),
      StoredNote,
      PrefetchHooks Function()
    >;

class $NotesDatabaseManager {
  final _$NotesDatabase _db;
  $NotesDatabaseManager(this._db);
  $$NoteRecordsTableTableManager get noteRecords =>
      $$NoteRecordsTableTableManager(_db, _db.noteRecords);
}
