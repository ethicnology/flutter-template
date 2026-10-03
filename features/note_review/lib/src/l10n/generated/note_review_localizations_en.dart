// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'note_review_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class NoteReviewLocalizationsEn extends NoteReviewLocalizations {
  NoteReviewLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Review';

  @override
  String count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
      zero: 'No notes to review yet.',
    );
    return '$_temp0';
  }

  @override
  String get retry => 'Try again';

  @override
  String get unavailable =>
      'Your notes are temporarily unavailable. Try again.';
}
