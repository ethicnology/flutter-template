import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:notes/notes.dart';
import 'package:result/result.dart';
import 'package:ui_kit/ui_kit.dart';

import 'failure_message.dart';
import 'l10n/generated/note_capture_localizations.dart';
import 'note_capture_screen.dart';

/// Internal lifecycle host. The opener transfers ownership of a successful handle.
final class NoteCaptureHost extends StatefulWidget {
  const NoteCaptureHost({required this.open, super.key});

  final Future<Result<Notes, NotesFailure>> Function() open;

  @override
  State<NoteCaptureHost> createState() => _NoteCaptureHostState();
}

final class _NoteCaptureHostState extends State<NoteCaptureHost> {
  Notes? _notes;
  NotesFailure? _failure;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    unawaited(_open());
  }

  Future<void> _open() async {
    if (_opening) return;
    setState(() {
      _opening = true;
      _failure = null;
    });
    final outcome = await widget.open();
    if (!mounted) {
      if (outcome case Success(:final value)) {
        await value.close();
      }
      return;
    }
    setState(() {
      _opening = false;
      switch (outcome) {
        case Success(:final value):
          _notes = value;
        case Failure(:final failure):
          _failure = failure;
      }
    });
  }

  @override
  void dispose() {
    final notes = _notes;
    if (notes != null) unawaited(notes.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = _notes;
    if (notes != null) return NoteCaptureScreen(notes: notes);
    final strings = NoteCaptureLocalizations.of(context);
    return UiPage(
      title: strings.title,
      child: _opening
          ? const UiLoading()
          : UiColumn(
              children: [
                if (_failure case final failure?)
                  UiError(failureMessage(failure, strings)),
                UiButton(label: strings.retry, onPressed: _open),
              ],
            ),
    );
  }
}
