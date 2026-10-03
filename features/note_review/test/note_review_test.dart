import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_review/note_review.dart';
import 'package:notes/notes.dart';
import 'package:notes_testing/notes_testing.dart';
import 'package:result/result.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgetsWithNotes('shows notes written through the public API', (
    tester,
    notes,
  ) async {
    await tester.runAsync(() async {
      await notes.add('Older');
      await notes.add('Newer');
    });
    await pumpWithNotes(tester, _app(notes), notes);

    expect(find.text('2 notes'), findsOneWidget);
    final tiles = tester.widgetList<UiListTile>(find.byType(UiListTile));
    expect(tiles.map((tile) => tile.title), ['Newer', 'Older']);
  });

  testWidgetsWithNotes('reflects writes made outside this journey', (
    tester,
    notes,
  ) async {
    await pumpWithNotes(tester, _app(notes), notes);
    expect(find.text('No notes to review yet.'), findsOneWidget);

    await settleNotes(
      tester,
      notes,
      action: () => notes.add('Written elsewhere'),
    );
    expect(find.text('1 note'), findsOneWidget);
    expect(find.text('Written elsewhere'), findsOneWidget);
  });

  testWidgetsWithNotes('never closes the borrowed collection on disposal', (
    tester,
    notes,
  ) async {
    await pumpWithNotes(tester, _app(notes), notes);
    final afterDisposal = await tester.runAsync(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      return notes.add('Still open');
    });
    expect(afterDisposal, isA<Success<Note, NotesFailure>>());
  });

  testWidgetsWithNotes(
    'unavailable storage exposes a localized retry instead of an exception',
    (tester, notes) async {
      await tester.runAsync(notes.close);
      await pumpWithNotes(
        tester,
        _app(notes, locale: const Locale('fr')),
        notes,
      );
      final strings = NoteReviewLocalizations.of(
        tester.element(find.byType(NoteReviewScreen)),
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

Widget _app(Notes notes, {Locale locale = const Locale('en')}) => UiKitApp(
  title: 'Note review test',
  locale: locale,
  supportedLocales: NoteReviewLocalizations.supportedLocales,
  localizationsDelegates: [NoteReviewLocalizations.delegate],
  home: NoteReviewScreen(notes: notes),
);
