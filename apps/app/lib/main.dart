import 'package:diagnostics/diagnostics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:note_capture/note_capture.dart';
import 'package:note_review/note_review.dart';
import 'package:notes/notes.dart';
import 'package:result/result.dart';
import 'package:ui_kit/ui_kit.dart';

import 'l10n/generated/app_localizations.dart';
import 'notes_owner.dart';

void main() => runApp(const TemplateApp());

/// Composes the shared visual system, every feature's localization delegates,
/// and the journeys. Tests inject an opener that returns disposable storage.
class TemplateApp extends StatelessWidget {
  /// Full exceptions for a developer; redacted codes everywhere else.
  const TemplateApp({
    this.diagnostics = kDebugMode
        ? const DebugDiagnostics()
        : const RedactedDiagnostics(),
    this.open = Notes.open,
    this.locale,
    super.key,
  });

  final DiagnosticSink diagnostics;
  final Future<Result<Notes, NotesFailure>> Function({
    required DiagnosticSink diagnostics,
  })
  open;
  final Locale? locale;

  @override
  Widget build(BuildContext context) => UiKitApp(
    title: 'Modular App',
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      NoteCaptureLocalizations.delegate,
      NoteReviewLocalizations.delegate,
    ],
    home: NotesOwner(
      open: () => open(diagnostics: diagnostics),
      builder: (_, notes) => AppHome(notes: notes),
    ),
  );
}

/// Global navigation between journeys that borrow the same collection.
/// Only the selected journey is mounted; each one loads its snapshot on entry.
final class AppHome extends StatefulWidget {
  const AppHome({required this.notes, super.key});

  final Notes notes;

  @override
  State<AppHome> createState() => _AppHomeState();
}

final class _AppHomeState extends State<AppHome> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return UiNavigation(
      destinations: [
        UiDestination(label: strings.captureDestination, icon: UiIcon.compose),
        UiDestination(label: strings.reviewDestination, icon: UiIcon.review),
      ],
      selectedIndex: _selected,
      onSelected: (index) => setState(() => _selected = index),
      // The only place where capture and review meet: the capture journey
      // exposes an intent, the shell decides it leads to the review tab.
      child: switch (_selected) {
        0 => NoteCaptureScreen(
          notes: widget.notes,
          onReviewRequested: () => setState(() => _selected = 1),
        ),
        _ => NoteReviewScreen(notes: widget.notes),
      },
    );
  }
}
