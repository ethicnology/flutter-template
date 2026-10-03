// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'note_capture_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class NoteCaptureLocalizationsEn extends NoteCaptureLocalizations {
  NoteCaptureLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Notes';

  @override
  String get noteLabel => 'Your note';

  @override
  String get save => 'Save note';

  @override
  String get retry => 'Try again';

  @override
  String get empty => 'No notes yet. Write your first note above.';

  @override
  String get emptyNote => 'Write a note before saving.';

  @override
  String noteTooLong(int maxLength) {
    return 'Use no more than $maxLength characters.';
  }

  @override
  String get unavailable =>
      'Your notes are temporarily unavailable. Try again.';

  @override
  String get saved => 'Note saved.';
}
