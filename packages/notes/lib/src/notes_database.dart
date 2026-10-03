import 'package:drift/drift.dart';

part 'notes_database.g.dart';

@DataClassName('StoredNote')
class NoteRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [NoteRecords])
class NotesDatabase extends _$NotesDatabase {
  NotesDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  SimpleSelectStatement<$NoteRecordsTable, StoredNote> get _newestFirst =>
      select(noteRecords)..orderBy([(row) => OrderingTerm.desc(row.id)]);

  Future<List<StoredNote>> readNotes() => _newestFirst.get();

  Stream<List<StoredNote>> watchNotes() => _newestFirst.watch();

  Future<StoredNote> insertNote(String text) => into(noteRecords)
      .insertReturning(
        NoteRecordsCompanion.insert(
          content: text,
          createdAt: DateTime.now().toUtc(),
        ),
      );
}
