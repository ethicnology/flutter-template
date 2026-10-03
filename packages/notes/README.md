# Notes

Owns a small local collection of text notes, including its private SQLite database, schema, validation, and storage diagnostics. Use it to add and list notes. It does not render screens, localize messages, synchronize data, or implement general application storage.

## Public usage

```dart
final opened = await Notes.open(diagnostics: diagnostics);
switch (opened) {
  case Success<Notes, NotesFailure>(:final value):
    final outcome = await value.add('Remember the module boundary');
    // Handle the typed outcome in the caller's presentation or orchestration.
    await value.close();
  case Failure<Notes, NotesFailure>(:final failure):
    // Present a localized recovery action for this typed failure.
}
```

Import `package:notes/notes.dart` and `package:result/result.dart`. The `note_capture` feature is the executable consumer example. Tests in `test/notes_test.dart` use the same public operations.

## Ownership and lifecycle

`Notes.open` owns directory discovery and opens `<application support>/notes/notes.sqlite`. `Notes.inMemory` creates disposable storage; `Notes.atFile` provides an explicit location for tests and embedding. Both still hide Drift and table access. Own one instance per database file, share it with consumers, and await `close` after removing those consumers. A route owns a collection used only during that route; a capability shared by several routes needs one longer-lived owner. The one-screen example mounts one `NoteCaptureFeature`; shared collections are passed through `NoteCaptureScreen` instead of opening the same file from each journey. Do not rely on widget disposal for crash durability, because process termination need not call it. Close drains previously accepted operations and rejects later operations. No consumer accesses this database directly.

The schema starts at version 1. A future schema change needs migration tests against the last released schema; generated Drift code is produced from `lib/src/notes_database.dart`. This starter has no earlier released schema to migrate.

## Contract and failures

`add` trims surrounding whitespace, rejects empty text, and allows at most 500 Unicode scalar values. Successful insertion returns the persisted note. `list` returns an immutable newest-first snapshot for one-off reads. `watch` emits that snapshot now and after every change, each listener with its own query; it completes when the collection closes, and a storage failure emits one `NotesUnavailable` and completes, so observing again is the recovery action. Screens render the latest emission instead of keeping their own copy. The sample has no pagination or cross-process coordination.

`EmptyNote` and `NoteTooLong` are normal validation outcomes and are not logged. Storage failures produce `NotesUnavailable` and one owner diagnostic per failed operation. The original exception and stack are sent to the developer diagnostic sink. SQLite messages can contain parameters: the default sink emits only a constant code and exception type, and every alternative sink must redact before logging or transmitting. Presentation chooses the user's words and recovery action.

## Verification

The workspace commands generate Drift code, analyze this package, and run its tests. Coverage includes durable close/reopen, validation, Unicode limits, draining close, observation across writes and close, and sanitized storage-failure diagnostics. Widget tests of consumers go through `notes_testing`. Native SQLite makes this example suitable for Android, iOS, and desktop; web persistence is outside its scope.
