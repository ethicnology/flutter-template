import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_capture/note_capture.dart';
import 'package:note_review/note_review.dart';
import 'package:notes/notes.dart';
import 'package:notes_testing/notes_testing.dart';
import 'package:result/result.dart';
import 'package:template_app/l10n/generated/app_localizations.dart';
import 'package:template_app/main.dart';

void main() {
  testWidgetsWithNotes(
    'journeys share one collection and the shell closes it on disposal',
    (tester, notes) async {
      var opened = 0;
      await pumpWithNotes(
        tester,
        TemplateApp(
          open: ({required diagnostics}) async {
            opened++;
            return Success(notes);
          },
        ),
        notes,
      );
      expect(opened, 1);
      expect(find.byType(NoteCaptureScreen), findsOneWidget);

      await tester.enterText(find.byType(EditableText), 'Shared note');
      await settleNotes(
        tester,
        notes,
        action: () => tester.tap(find.text('Save note')),
      );
      expect(find.text('Note saved.'), findsOneWidget);

      // The capture journey's intent, wired by the shell, opens the review.
      await settleNotes(
        tester,
        notes,
        action: () => tester.tap(find.text('See all notes')),
      );
      expect(find.byType(NoteCaptureScreen), findsNothing);
      expect(find.byType(NoteReviewScreen), findsOneWidget);
      expect(find.text('1 note'), findsOneWidget);
      expect(find.text('Shared note'), findsOneWidget);
      expect(opened, 1);

      final afterDisposal = await tester.runAsync(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        return notes.list();
      });
      expect(afterDisposal, isA<Failure<List<Note>, NotesFailure>>());
    },
  );

  testWidgetsWithNotes('startup failure shows a localized retry in the shell', (
    tester,
    notes,
  ) async {
    var attempts = 0;
    await pumpWithNotes(
      tester,
      TemplateApp(
        locale: const Locale('fr'),
        open: ({required diagnostics}) async {
          attempts++;
          return attempts == 1
              ? const Failure(NotesUnavailable())
              : Success(notes);
        },
      ),
      notes,
    );
    expect(
      find.text('Vos notes sont temporairement indisponibles. Réessayez.'),
      findsOneWidget,
    );
    expect(find.textContaining('NotesUnavailable'), findsNothing);

    await settleNotes(
      tester,
      notes,
      action: () => tester.tap(find.text('Réessayer')),
    );
    expect(attempts, 2);
    expect(find.byType(NoteCaptureScreen), findsOneWidget);
    expect(find.text('Saisie'), findsOneWidget);
    expect(find.text('Relecture'), findsOneWidget);
  });

  test('every feature supports each locale the shell offers', () {
    for (final locale in AppLocalizations.supportedLocales) {
      expect(NoteCaptureLocalizations.delegate.isSupported(locale), isTrue);
      expect(NoteReviewLocalizations.delegate.isSupported(locale), isTrue);
    }
  });
}
