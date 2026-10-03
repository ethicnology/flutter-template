import 'dart:async';
import 'dart:io';

import 'package:diagnostics/diagnostics.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:result/result.dart';

import 'note.dart';
import 'notes_database.dart';
import 'notes_failure.dart';

/// Owns a collection's storage, migrations, and diagnostic boundary.
///
/// Open one instance per database file. Share it between consumers and close it
/// only after they have stopped using it. Calls queued before [close] finish
/// before storage closes; later calls return [NotesUnavailable].
final class Notes {
  Notes._(this._database, this._diagnostics);

  static const maxNoteLength = 500;

  final NotesDatabase _database;
  final DiagnosticSink _diagnostics;
  Future<void> _pending = Future<void>.value();
  Future<void>? _closing;

  /// Opens the module-owned database in application support storage.
  ///
  /// Directory initialization failures are sanitized before leaving this module.
  static Future<Result<Notes, NotesFailure>> open({
    required DiagnosticSink diagnostics,
  }) async {
    try {
      final support = await getApplicationSupportDirectory();
      final directory = Directory(path.join(support.path, 'notes'));
      await directory.create(recursive: true);
      final notes = Notes.atFile(
        File(path.join(directory.path, 'notes.sqlite')),
        diagnostics: diagnostics,
      );
      final ready = await notes.list();
      if (ready case Failure(:final failure)) {
        await notes.close();
        return Failure(failure);
      }
      return Success(notes);
    } on Exception catch (error, stackTrace) {
      diagnostics.record(
        'notes.initialize_failed',
        error: error,
        stackTrace: stackTrace,
      );
      return const Failure(NotesUnavailable());
    }
  }

  /// Creates an isolated collection for a test or disposable example session.
  factory Notes.inMemory({required DiagnosticSink diagnostics}) =>
      Notes._(NotesDatabase(NativeDatabase.memory()), diagnostics);

  /// Opens storage at an explicit location for tests and controlled embedding.
  ///
  /// The parent directory must already exist. This does not expose a database
  /// connection or allow consumers to read the module's tables.
  factory Notes.atFile(File file, {required DiagnosticSink diagnostics}) =>
      Notes._(NotesDatabase(NativeDatabase(file)), diagnostics);

  /// Returns the newest inserted notes first.
  Future<Result<List<Note>, NotesFailure>> list() => _enqueue(() async {
    try {
      final rows = await _database.readNotes();
      return Success(List<Note>.unmodifiable(rows.map(_toNote)));
    } on Exception catch (error, stackTrace) {
      _recordStorageFailure('notes.list_failed', error, stackTrace);
      return const Failure(NotesUnavailable());
    }
  });

  /// Emits the newest-first snapshot now and after every change, until the
  /// collection closes; the stream then completes. A storage failure emits one
  /// [NotesUnavailable] and completes. After [close], it emits that failure
  /// once and completes. Each listener gets its own query.
  Stream<Result<List<Note>, NotesFailure>> watch() {
    if (_closing != null) {
      return Stream.value(const Failure(NotesUnavailable()));
    }
    final controller = StreamController<Result<List<Note>, NotesFailure>>();
    late final StreamSubscription<List<StoredNote>> rows;
    controller.onListen = () {
      rows = _database.watchNotes().listen(
        (stored) => controller.add(
          Success(List<Note>.unmodifiable(stored.map(_toNote))),
        ),
        onError: (Object error, StackTrace stackTrace) {
          if (error is Exception) {
            _recordStorageFailure('notes.watch_failed', error, stackTrace);
            controller.add(const Failure(NotesUnavailable()));
            unawaited(controller.close());
          } else {
            controller.addError(error, stackTrace);
          }
        },
        onDone: controller.close,
      );
    };
    controller.onCancel = () => rows.cancel();
    return controller.stream;
  }

  /// Trims whitespace and stores a non-empty note of at most 500 Unicode scalars.
  Future<Result<Note, NotesFailure>> add(String text) => _enqueue(() async {
    final normalized = text.trim();
    if (normalized.isEmpty) return const Failure(EmptyNote());
    if (normalized.runes.length > maxNoteLength) {
      return const Failure(NoteTooLong(maxNoteLength));
    }
    try {
      return Success(_toNote(await _database.insertNote(normalized)));
    } on Exception catch (error, stackTrace) {
      _recordStorageFailure('notes.add_failed', error, stackTrace);
      return const Failure(NotesUnavailable());
    }
  });

  Future<Result<T, NotesFailure>> _enqueue<T>(
    Future<Result<T, NotesFailure>> Function() operation,
  ) {
    if (_closing != null) {
      return Future.value(const Failure(NotesUnavailable()));
    }
    final next = _pending.then((_) => operation());
    _pending = next.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return next;
  }

  /// Releases resources after pending operations finish. Safe to call repeatedly.
  Future<void> close() => _closing ??= _pending.then((_) async {
    try {
      await _database.close();
    } on Exception catch (error, stackTrace) {
      _recordStorageFailure('notes.close_failed', error, stackTrace);
    }
  });

  void _recordStorageFailure(String code, Object error, StackTrace stackTrace) {
    // The diagnostic adapter must redact before logging or transmission.
    _diagnostics.record(code, error: error, stackTrace: stackTrace);
  }

  static Note _toNote(StoredNote row) =>
      Note(id: row.id, text: row.content, createdAt: row.createdAt.toUtc());
}
