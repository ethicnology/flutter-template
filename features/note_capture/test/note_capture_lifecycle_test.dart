import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_capture/note_capture.dart';
import 'package:note_capture/src/note_capture_host.dart';
import 'package:notes/notes.dart';
import 'package:notes_testing/notes_testing.dart';
import 'package:result/result.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgetsWithNotes(
    'retries initialization and closes its acquired collection on disposal',
    (tester, notes) async {
      var attempts = 0;
      Future<Result<Notes, NotesFailure>> open() async {
        attempts++;
        return attempts == 1
            ? const Failure(NotesUnavailable())
            : Success(notes);
      }

      await pumpWithNotes(tester, _app(open), notes);
      final strings = NoteCaptureLocalizations.of(
        tester.element(find.byType(NoteCaptureHost)),
      );
      expect(find.text(strings.unavailable), findsOneWidget);
      expect(attempts, 1);

      await settleNotes(
        tester,
        notes,
        action: () => tester.tap(find.text(strings.retry)),
      );
      expect(attempts, 2);
      expect(find.byType(NoteCaptureScreen), findsOneWidget);
      expect(find.text(strings.unavailable), findsNothing);

      final afterDisposal = await tester.runAsync(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        return notes.list();
      });
      expect(afterDisposal, isA<Failure<List<Note>, NotesFailure>>());
    },
  );

  testWidgetsWithNotes(
    'closes a collection that opens after its route was removed',
    (tester, notes) async {
      var attempts = 0;
      final afterLateOpen = await tester.runAsync(() async {
        final opened = Completer<Result<Notes, NotesFailure>>();
        await tester.pumpWidget(
          _app(() {
            attempts++;
            return opened.future;
          }),
        );
        expect(find.byType(UiLoading), findsOneWidget);
        expect(attempts, 1);
        await tester.pumpWidget(const SizedBox.shrink());
        opened.complete(Success(notes));
        await Future<void>.delayed(Duration.zero);
        await tester.pump();
        return notes.list();
      });
      expect(afterLateOpen, isA<Failure<List<Note>, NotesFailure>>());
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _app(Future<Result<Notes, NotesFailure>> Function() open) => UiKitApp(
  title: 'Lifecycle test',
  supportedLocales: NoteCaptureLocalizations.supportedLocales,
  localizationsDelegates: [NoteCaptureLocalizations.delegate],
  home: NoteCaptureHost(open: open),
);
