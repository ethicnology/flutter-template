# Notes testing

Widget-test helpers for journeys over a real `Notes` collection. Use it from any feature or shell test; it is a development dependency only.

## Why it exists

`flutter_test` simulates time, while native SQLite completes in real time. A storage future created in the simulated zone never completes there, and one that `tearDown` awaits after the body ends hangs the whole run for ten minutes with no message. The rule is simple but easy to forget, so these helpers apply it for you.

## Usage

```dart
testWidgetsWithNotes('captures a note', (tester, notes) async {
  await pumpWithNotes(tester, app(notes), notes);
  await tester.enterText(find.byType(EditableText), 'Hello');
  await settleNotes(tester, notes, action: () => tester.tap(find.text('Save')));
  expect(find.text('Hello'), findsOneWidget);
});
```

`testWidgetsWithNotes` opens an in-memory collection, runs the body, then unmounts the tree and closes the collection in the real zone, even when the body fails. `pumpWithNotes` mounts a widget and lets storage finish what mounting queued. `settleNotes` runs an optional action, drains storage, lets observed queries deliver, and settles frames. `SilentDiagnostics` is a sink for tests that do not assert on diagnostics.

Keep `tester.runAsync` for anything else that touches storage directly, such as reading the collection to assert on persisted data.
