// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'note_capture_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class NoteCaptureLocalizationsFr extends NoteCaptureLocalizations {
  NoteCaptureLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get title => 'Notes';

  @override
  String get noteLabel => 'Votre note';

  @override
  String get save => 'Enregistrer la note';

  @override
  String get retry => 'Réessayer';

  @override
  String get empty =>
      'Aucune note pour le moment. Écrivez votre première note ci-dessus.';

  @override
  String get emptyNote => 'Écrivez une note avant de l’enregistrer.';

  @override
  String noteTooLong(int maxLength) {
    return 'Utilisez au maximum $maxLength caractères.';
  }

  @override
  String get unavailable =>
      'Vos notes sont temporairement indisponibles. Réessayez.';

  @override
  String get saved => 'Note enregistrée.';
}
