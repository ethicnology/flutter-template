import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:notes/notes.dart';
import 'package:result/result.dart';
import 'package:ui_kit/ui_kit.dart';

import 'failure_message.dart';
import 'l10n/generated/note_capture_localizations.dart';
import 'note_capture_controller.dart';
import 'note_capture_state.dart';

/// Renders the journey using an already-open collection owned by its caller.
final class NoteCaptureScreen extends StatefulWidget {
  const NoteCaptureScreen({required this.notes, super.key});

  final Notes notes;

  @override
  State<NoteCaptureScreen> createState() => _NoteCaptureScreenState();
}

final class _NoteCaptureScreenState extends State<NoteCaptureScreen> {
  final _input = TextEditingController();
  late NoteCaptureController _controller;
  late Stream<Result<List<Note>, NotesFailure>> _list;

  @override
  void initState() {
    super.initState();
    _attach();
  }

  void _attach() {
    _controller = NoteCaptureController(widget.notes)
      ..addListener(_onStateChanged);
    _list = widget.notes.watch();
  }

  void _onStateChanged() => setState(() {});

  @override
  void didUpdateWidget(NoteCaptureScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.notes, widget.notes)) {
      _controller.dispose();
      _attach();
    }
  }

  /// A failed stream has completed; observing again is the recovery action.
  void _observeAgain() => setState(() => _list = widget.notes.watch());

  Future<void> _save() async {
    final controller = _controller;
    final submittedRevision = controller.inputRevision;
    final saved = await controller.save(_input.text);
    if (!mounted || !identical(controller, _controller)) return;
    if (saved && controller.inputRevision == submittedRevision) _input.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = NoteCaptureLocalizations.of(context);
    final submission = _controller.submission;
    return UiPage(
      title: strings.title,
      child: StreamBuilder(
        stream: _list,
        builder: (context, snapshot) {
          final list = snapshot.data;
          final unavailable = list is Failure<List<Note>, NotesFailure>;
          return UiColumn(
            children: [
              UiTextField(
                label: strings.noteLabel,
                controller: _input,
                onChanged: (_) => _controller.inputChanged(),
                errorText: switch (submission) {
                  Rejected(failure: EmptyNote() || NoteTooLong()) =>
                    failureMessage(submission.failure, strings),
                  _ => null,
                },
              ),
              UiButton(
                label: strings.save,
                onPressed: submission is Submitting || unavailable
                    ? null
                    : _save,
                busy: submission is Submitting,
              ),
              if (submission case Rejected(failure: NotesUnavailable()))
                UiError(strings.unavailable),
              if (submission is Submitted) UiText(strings.saved),
              switch (list) {
                null => const UiLoading(),
                Failure(:final failure) => UiColumn(
                  children: [
                    UiError(failureMessage(failure, strings)),
                    UiButton(label: strings.retry, onPressed: _observeAgain),
                  ],
                ),
                Success(value: final notes) when notes.isEmpty => UiEmpty(
                  strings.empty,
                ),
                Success(value: final notes) => UiList(
                  children: [
                    for (final note in notes)
                      UiListTile(key: ValueKey(note.id), title: note.text),
                  ],
                ),
              },
            ],
          );
        },
      ),
    );
  }
}
