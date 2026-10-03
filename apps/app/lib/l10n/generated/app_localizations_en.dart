// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Modular App';

  @override
  String get captureDestination => 'Capture';

  @override
  String get reviewDestination => 'Review';

  @override
  String get unavailable =>
      'Your notes are temporarily unavailable. Try again.';

  @override
  String get retry => 'Try again';
}
