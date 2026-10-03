import 'package:notes/notes.dart';

import 'l10n/generated/note_capture_localizations.dart';

String failureMessage(NotesFailure failure, NoteCaptureLocalizations strings) =>
    switch (failure) {
      EmptyNote() => strings.emptyNote,
      NoteTooLong(:final maxLength) => strings.noteTooLong(maxLength),
      NotesUnavailable() => strings.unavailable,
    };
