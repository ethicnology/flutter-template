import 'dart:io';

import 'package:diagnostics/diagnostics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/notes.dart';
import 'package:result/result.dart';

void main() {
  test('rejects invalid input without storing or reporting it', () async {
    final diagnostics = _Diagnostics();
    final notes = Notes.inMemory(diagnostics: diagnostics);
    addTearDown(notes.close);

    expect(await notes.add('  '), isA<Failure>());
    final empty = await notes.add('');
    expect((empty as Failure).failure, isA<EmptyNote>());
    final tooLong = await notes.add('x' * (Notes.maxNoteLength + 1));
    expect((tooLong as Failure).failure, isA<NoteTooLong>());
    final contents = await notes.list();
    expect((contents as Success).value, isEmpty);
    expect(diagnostics.events, isEmpty);
  });

  test(
    'trims text and counts Unicode scalars rather than UTF-16 units',
    () async {
      final notes = Notes.inMemory(diagnostics: _Diagnostics());
      addTearDown(notes.close);
      final text = String.fromCharCode(0x1f642) * Notes.maxNoteLength;
      final added = await notes.add('  $text  ');
      expect((added as Success).value.text, text);
    },
  );

  test(
    'persists data across close and reopen with newest-first ordering',
    () async {
      final directory = await Directory.systemTemp.createTemp('notes_test_');
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/notes.sqlite');
      final notes = Notes.atFile(file, diagnostics: _Diagnostics());
      await notes.add('First note');
      await notes.add(' Second note ');
      await notes.close();

      final reopened = Notes.atFile(file, diagnostics: _Diagnostics());
      addTearDown(reopened.close);
      final contents = await reopened.list();
      expect((contents as Success).value.map((n) => n.text), [
        'Second note',
        'First note',
      ]);
    },
  );

  test(
    'close drains accepted writes and rejects subsequent operations',
    () async {
      final notes = Notes.inMemory(diagnostics: _Diagnostics());
      final accepted = notes.add('Accepted');
      final closing = notes.close();
      final rejected = await notes.add('Too late');
      expect(await accepted, isA<Success>());
      expect((rejected as Failure).failure, isA<NotesUnavailable>());
      await closing;
      await notes.close();
    },
  );

  test('watch emits the current snapshot and every later change', () async {
    final notes = Notes.inMemory(diagnostics: _Diagnostics());
    addTearDown(notes.close);
    final snapshots = <List<String>>[];
    final subscription = notes.watch().listen((outcome) {
      if (outcome case Success(:final value)) {
        snapshots.add([for (final note in value) note.text]);
      }
    });
    addTearDown(subscription.cancel);
    await notes.add('First');
    await notes.add('Second');
    await Future<void>.delayed(Duration.zero);
    expect(snapshots.last, ['Second', 'First']);
    expect(snapshots.first, anyOf(isEmpty, ['First']));
  });

  test('watch completes when the collection closes', () async {
    final notes = Notes.inMemory(diagnostics: _Diagnostics());
    final done = notes.watch().toList();
    await notes.add('Before close');
    // Let the query emit before storage closes underneath it.
    await Future<void>.delayed(Duration.zero);
    await notes.close();
    final emitted = await done;
    expect(emitted, isNotEmpty);
    expect(emitted.last, isA<Success<List<Note>, NotesFailure>>());
    expect(
      (await notes.watch().toList()).single,
      isA<Failure<List<Note>, NotesFailure>>(),
    );
  });

  test(
    'storage failure emits one sanitized diagnostic and a typed failure',
    () async {
      final directory = await Directory.systemTemp.createTemp('notes_failure_');
      addTearDown(() => directory.delete(recursive: true));
      final diagnostics = _Diagnostics();
      // A directory cannot be opened as a SQLite database file.
      final notes = Notes.atFile(
        File(directory.path),
        diagnostics: diagnostics,
      );
      addTearDown(notes.close);
      const privateText = 'Private note content must never enter diagnostics';

      final outcome = await notes.add(privateText);
      expect((outcome as Failure).failure, isA<NotesUnavailable>());
      expect(diagnostics.events, hasLength(1));
      expect(diagnostics.originals.single, isA<Exception>());
      expect(diagnostics.events.single, contains('notes.add_failed'));
      expect(diagnostics.events.single, isNot(contains(privateText)));
      expect(diagnostics.events.single, isNot(contains(directory.path)));
    },
  );
}

final class _Diagnostics implements DiagnosticSink {
  final events = <String>[];
  final originals = <Object>[];

  @override
  void record(
    String code, {
    required Object error,
    required StackTrace stackTrace,
  }) {
    originals.add(error);
    events.add(diagnosticSummary(code, error));
  }
}
