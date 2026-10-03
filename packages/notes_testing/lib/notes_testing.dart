/// Widget-test support for journeys over a real `Notes` collection.
///
/// `flutter_test` simulates time, while native SQLite completes in real time.
/// A storage future created in the simulated zone can never complete there,
/// and one awaited by `tearDown` after the body ends hangs the whole run with
/// no message. These helpers keep every storage interaction in the real zone
/// so tests can be written without knowing that rule.
library;

import 'package:diagnostics/diagnostics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/notes.dart';

/// A sink for tests that do not assert on diagnostics.
final class SilentDiagnostics implements DiagnosticSink {
  const SilentDiagnostics();

  @override
  void record(
    String code, {
    required Object error,
    required StackTrace stackTrace,
  }) {}
}

/// Runs [body] with a disposable in-memory collection. The tree is unmounted
/// and the collection closed in the real zone after [body], even on failure.
void testWidgetsWithNotes(
  String description,
  Future<void> Function(WidgetTester tester, Notes notes) body,
) {
  testWidgets(description, (tester) async {
    final notes = Notes.inMemory(diagnostics: const SilentDiagnostics());
    await tester.runAsync(notes.list);
    try {
      await body(tester, notes);
    } finally {
      await tester.runAsync(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await notes.close();
      });
    }
  });
}

/// Mounts [widget], lets storage finish the work that mounting queued, and
/// settles frames.
Future<void> pumpWithNotes(WidgetTester tester, Widget widget, Notes notes) {
  return tester.runAsync(() => tester.pumpWidget(widget)).then((_) {
    return settleNotes(tester, notes);
  });
}

/// Runs [action], if any, then waits for storage to drain and frames to
/// settle. Use it after a tap, an edit or an external write.
Future<void> settleNotes(
  WidgetTester tester,
  Notes notes, {
  Future<void> Function()? action,
}) async {
  await tester.runAsync(() async {
    if (action != null) await action();
    // Turn the real event loop, mount whatever that produced, drain storage,
    // then let stream queries deliver before frames settle.
    await Future<void>.delayed(Duration.zero);
    await tester.pump();
    await notes.list();
    await Future<void>.delayed(Duration.zero);
  });
  await tester.pumpAndSettle();
}
