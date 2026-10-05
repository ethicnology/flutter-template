import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_capture/note_capture.dart';
import 'package:notes/notes.dart';
import 'package:notes_testing/notes_testing.dart';
import 'package:result/result.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgetsWithNotes(
    'preserves a newer draft even when its text returns to the submitted value',
    (tester, notes) async {
      await pumpWithNotes(tester, _app(notes), notes);
      await tester.enterText(find.byType(EditableText), 'A');

      await settleNotes(
        tester,
        notes,
        action: () async {
          final field = tester.widget<UiTextField>(find.byType(UiTextField));
          final button = tester.widget<UiButton>(find.byType(UiButton));
          button.onPressed!();
          // Deliver two editing events before the accepted write completes.
          field.controller!.text = 'B';
          field.onChanged('B');
          field.controller!.text = 'A';
          field.onChanged('A');
        },
      );

      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        'A',
      );
      expect(find.text('Note saved.'), findsNothing);
      final stored = await tester.runAsync(notes.list);
      expect((stored as Success).value.single.text, 'A');
    },
  );

  testWidgetsWithNotes('captures a note through the public module interface', (
    tester,
    notes,
  ) async {
    await pumpWithNotes(tester, _app(notes), notes);
    expect(
      find.text('No notes yet. Write your first note above.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byType(EditableText),
      'A note from the feature',
    );
    await settleNotes(
      tester,
      notes,
      action: () => tester.tap(find.text('Save note')),
    );

    expect(find.text('Note saved.'), findsOneWidget);
    expect(find.text('A note from the feature'), findsOneWidget);
    final stored = await tester.runAsync(notes.list);
    expect((stored as Success).value.single.text, 'A note from the feature');
  });

  testWidgetsWithNotes('hides the review action when no intent is wired', (
    tester,
    notes,
  ) async {
    await pumpWithNotes(tester, _app(notes), notes);
    expect(find.text('See all notes'), findsNothing);
  });

  testWidgetsWithNotes('reports a review request without knowing the target', (
    tester,
    notes,
  ) async {
    var requests = 0;
    await pumpWithNotes(
      tester,
      _app(notes, onReviewRequested: () => requests++),
      notes,
    );
    await tester.tap(find.text('See all notes'));
    expect(requests, 1);
  });

  testWidgetsWithNotes('shows notes written by another journey', (
    tester,
    notes,
  ) async {
    await pumpWithNotes(tester, _app(notes), notes);
    await settleNotes(
      tester,
      notes,
      action: () => notes.add('Written elsewhere'),
    );
    expect(find.text('Written elsewhere'), findsOneWidget);
  });

  testWidgetsWithNotes(
    'keeps the failure typed and re-renders it when locale changes',
    (tester, notes) async {
      await pumpWithNotes(tester, _app(notes), notes);
      await settleNotes(
        tester,
        notes,
        action: () => tester.tap(find.text('Save note')),
      );
      expect(find.text('Write a note before saving.'), findsOneWidget);

      await tester.pumpWidget(_app(notes, locale: const Locale('fr')));
      await tester.pumpAndSettle();
      final strings = NoteCaptureLocalizations.of(
        tester.element(find.byType(NoteCaptureScreen)),
      );
      expect(find.text(strings.emptyNote), findsOneWidget);
      expect(find.text('Write a note before saving.'), findsNothing);
    },
  );

  testWidgetsWithNotes(
    'unavailable storage exposes a localized retry instead of an exception',
    (tester, notes) async {
      await tester.runAsync(notes.close);
      await pumpWithNotes(
        tester,
        _app(notes, locale: const Locale('fr')),
        notes,
      );
      final strings = NoteCaptureLocalizations.of(
        tester.element(find.byType(NoteCaptureScreen)),
      );
      expect(find.text(strings.unavailable), findsOneWidget);
      expect(find.text(strings.retry), findsOneWidget);
      expect(find.textContaining('NotesUnavailable'), findsNothing);
      await settleNotes(
        tester,
        notes,
        action: () => tester.tap(find.text(strings.retry)),
      );
      expect(find.text(strings.unavailable), findsOneWidget);
    },
  );
}

Widget _app(
  Notes notes, {
  Locale locale = const Locale('en'),
  VoidCallback? onReviewRequested,
}) => UiKitApp(
  title: 'Note capture test',
  locale: locale,
  supportedLocales: NoteCaptureLocalizations.supportedLocales,
  localizationsDelegates: [NoteCaptureLocalizations.delegate],
  home: NoteCaptureScreen(notes: notes, onReviewRequested: onReviewRequested),
);
