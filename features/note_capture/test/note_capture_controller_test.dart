import 'package:flutter_test/flutter_test.dart';
import 'package:note_capture/src/note_capture_controller.dart';
import 'package:note_capture/src/note_capture_state.dart';
import 'package:notes/notes.dart';
import 'package:notes_testing/notes_testing.dart';
import 'package:result/result.dart';

void main() {
  for (final text in ['', 'x' * (Notes.maxNoteLength + 1)]) {
    test(
      'discards validation for a draft edited during save (${text.length})',
      () async {
        final notes = Notes.inMemory(diagnostics: const SilentDiagnostics());
        addTearDown(notes.close);
        final controller = NoteCaptureController(notes);
        addTearDown(controller.dispose);

        final pending = controller.save(text);
        expect(controller.submission, isA<Submitting>());
        controller.inputChanged();
        expect(await pending, isFalse);
        expect(controller.submission, isA<Idle>());
      },
    );
  }

  test('keeps storage failures after the draft changes during save', () async {
    final notes = Notes.inMemory(diagnostics: const SilentDiagnostics());
    final controller = NoteCaptureController(notes);
    addTearDown(controller.dispose);
    await notes.close();

    final pending = controller.save('Submitted draft');
    controller.inputChanged();
    expect(await pending, isFalse);
    expect(
      controller.submission,
      isA<Rejected>().having(
        (r) => r.failure,
        'failure',
        isA<NotesUnavailable>(),
      ),
    );
  });

  test('keeps a completed write without marking a newer draft saved', () async {
    final notes = Notes.inMemory(diagnostics: const SilentDiagnostics());
    addTearDown(notes.close);
    final controller = NoteCaptureController(notes);
    addTearDown(controller.dispose);

    final pending = controller.save('Submitted draft');
    controller.inputChanged();
    expect(await pending, isTrue);
    expect(controller.submission, isA<Idle>());
    expect(
      (await notes.list() as Success).value.single.text,
      'Submitted draft',
    );
  });

  test('reports the saved draft and clears it on the next edit', () async {
    final notes = Notes.inMemory(diagnostics: const SilentDiagnostics());
    addTearDown(notes.close);
    final controller = NoteCaptureController(notes);
    addTearDown(controller.dispose);

    expect(await controller.save('Draft'), isTrue);
    expect(controller.submission, isA<Submitted>());
    controller.inputChanged();
    expect(controller.submission, isA<Idle>());
  });

  test(
    'prevents overlapping submissions from creating duplicate notes',
    () async {
      final notes = Notes.inMemory(diagnostics: const SilentDiagnostics());
      addTearDown(notes.close);
      final controller = NoteCaptureController(notes);
      addTearDown(controller.dispose);

      final first = controller.save('One submission');
      final repeated = controller.save('One submission');
      expect(await repeated, isFalse);
      expect(await first, isTrue);
      expect((await notes.list() as Success).value, hasLength(1));
    },
  );

  test(
    'ignores a late save result without claiming that disposal cancelled it',
    () async {
      final notes = Notes.inMemory(diagnostics: const SilentDiagnostics());
      addTearDown(notes.close);
      final controller = NoteCaptureController(notes);
      var notifications = 0;
      controller.addListener(() => notifications++);

      final pending = controller.save('Accepted before route disposal');
      final notificationCountAtDisposal = notifications;
      controller.dispose();

      expect(await pending, isFalse);
      expect(notifications, notificationCountAtDisposal);
      expect(
        (await notes.list() as Success).value.single.text,
        'Accepted before route disposal',
      );
    },
  );
}
