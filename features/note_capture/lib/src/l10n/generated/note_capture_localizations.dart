import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'note_capture_localizations_en.dart';
import 'note_capture_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of NoteCaptureLocalizations
/// returned by `NoteCaptureLocalizations.of(context)`.
///
/// Applications need to include `NoteCaptureLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/note_capture_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: NoteCaptureLocalizations.localizationsDelegates,
///   supportedLocales: NoteCaptureLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the NoteCaptureLocalizations.supportedLocales
/// property.
abstract class NoteCaptureLocalizations {
  NoteCaptureLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static NoteCaptureLocalizations of(BuildContext context) {
    return Localizations.of<NoteCaptureLocalizations>(
      context,
      NoteCaptureLocalizations,
    )!;
  }

  static const LocalizationsDelegate<NoteCaptureLocalizations> delegate =
      _NoteCaptureLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get title;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Your note'**
  String get noteLabel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save note'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'No notes yet. Write your first note above.'**
  String get empty;

  /// No description provided for @emptyNote.
  ///
  /// In en, this message translates to:
  /// **'Write a note before saving.'**
  String get emptyNote;

  /// No description provided for @noteTooLong.
  ///
  /// In en, this message translates to:
  /// **'Use no more than {maxLength} characters.'**
  String noteTooLong(int maxLength);

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Your notes are temporarily unavailable. Try again.'**
  String get unavailable;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Note saved.'**
  String get saved;
}

class _NoteCaptureLocalizationsDelegate
    extends LocalizationsDelegate<NoteCaptureLocalizations> {
  const _NoteCaptureLocalizationsDelegate();

  @override
  Future<NoteCaptureLocalizations> load(Locale locale) {
    return SynchronousFuture<NoteCaptureLocalizations>(
      lookupNoteCaptureLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_NoteCaptureLocalizationsDelegate old) => false;
}

NoteCaptureLocalizations lookupNoteCaptureLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return NoteCaptureLocalizationsEn();
    case 'fr':
      return NoteCaptureLocalizationsFr();
  }

  throw FlutterError(
    'NoteCaptureLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
