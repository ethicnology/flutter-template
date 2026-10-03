// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'note_review_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class NoteReviewLocalizationsFr extends NoteReviewLocalizations {
  NoteReviewLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get title => 'Relecture';

  @override
  String count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
      zero: 'Aucune note à relire pour le moment.',
    );
    return '$_temp0';
  }

  @override
  String get retry => 'Réessayer';

  @override
  String get unavailable =>
      'Vos notes sont temporairement indisponibles. Réessayez.';
}
