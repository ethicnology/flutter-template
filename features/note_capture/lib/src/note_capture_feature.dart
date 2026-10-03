import 'package:diagnostics/diagnostics.dart';
import 'package:flutter/widgets.dart';
import 'package:notes/notes.dart';

import 'note_capture_host.dart';

/// Owns collection initialization, startup recovery, and disposal.
/// Mount only one instance at a time for the default notes database.
final class NoteCaptureFeature extends StatelessWidget {
  const NoteCaptureFeature({required this.diagnostics, super.key});

  final DiagnosticSink diagnostics;

  @override
  Widget build(BuildContext context) =>
      NoteCaptureHost(open: () => Notes.open(diagnostics: diagnostics));
}
