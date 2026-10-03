// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get title => 'Application modulaire';

  @override
  String get captureDestination => 'Saisie';

  @override
  String get reviewDestination => 'Relecture';

  @override
  String get unavailable =>
      'Vos notes sont temporairement indisponibles. Réessayez.';

  @override
  String get retry => 'Réessayer';
}
