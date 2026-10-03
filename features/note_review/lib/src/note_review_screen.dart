import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:notes/notes.dart';
import 'package:result/result.dart';
import 'package:ui_kit/ui_kit.dart';

import 'l10n/generated/note_review_localizations.dart';

/// Observes a borrowed collection. The caller owns the collection and closes
/// it after this screen is gone; the screen never closes it.
final class NoteReviewScreen extends StatefulWidget {
  const NoteReviewScreen({required this.notes, super.key});

  final Notes notes;

  @override
  State<NoteReviewScreen> createState() => _NoteReviewScreenState();
}

final class _NoteReviewScreenState extends State<NoteReviewScreen> {
  late Stream<Result<List<Note>, NotesFailure>> _list = widget.notes.watch();

  @override
  void didUpdateWidget(NoteReviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.notes, widget.notes)) _observeAgain();
  }

  void _observeAgain() => setState(() => _list = widget.notes.watch());

  @override
  Widget build(BuildContext context) {
    final strings = NoteReviewLocalizations.of(context);
    return UiPage(
      title: strings.title,
      child: StreamBuilder(
        stream: _list,
        builder: (context, snapshot) => switch (snapshot.data) {
          null => const UiLoading(),
          Failure() => UiColumn(
            children: [
              UiError(strings.unavailable),
              UiButton(label: strings.retry, onPressed: _observeAgain),
            ],
          ),
          Success(value: final notes) => UiColumn(
            children: [
              UiText(strings.count(notes.length), role: UiTextRole.title),
              if (notes.isNotEmpty)
                UiList(
                  children: [
                    for (final note in notes)
                      UiListTile(key: ValueKey(note.id), title: note.text),
                  ],
                ),
            ],
          ),
        },
      ),
    );
  }
}
