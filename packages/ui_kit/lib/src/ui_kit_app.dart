import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'ui_tokens.dart';

/// Shared production themes, also used by the component catalog.
abstract final class UiThemes {
  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff275d56),
      brightness: brightness,
    ),
    useMaterial3: true,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(UiTokens.cornerRadius)),
      ),
    ),
  );
}

/// Applies the shared visual system and the caller's localization delegates.
class UiKitApp extends StatelessWidget {
  const UiKitApp({
    required this.title,
    required this.home,
    this.locale,
    this.supportedLocales = const [Locale('en')],
    this.localizationsDelegates,
    this.themeMode = ThemeMode.system,
    super.key,
  });

  final String title;
  final Widget home;
  final Locale? locale;
  final Iterable<Locale> supportedLocales;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: title,
    debugShowCheckedModeBanner: false,
    home: home,
    theme: UiThemes.light,
    darkTheme: UiThemes.dark,
    themeMode: themeMode,
    locale: locale,
    supportedLocales: supportedLocales,
    localizationsDelegates: [
      ...?localizationsDelegates,
      ...GlobalMaterialLocalizations.delegates,
    ],
  );
}
