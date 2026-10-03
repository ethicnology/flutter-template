import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:notes/notes.dart';
import 'package:result/result.dart';
import 'package:ui_kit/ui_kit.dart';

import 'l10n/generated/app_localizations.dart';

/// Owns one shared [Notes] handle for every journey built by [builder].
///
/// The handle opens when this widget mounts and closes when it is disposed,
/// after the journeys that borrow it are gone. A result that arrives after
/// disposal is closed immediately. Journeys never close the handle themselves.
final class NotesOwner extends StatefulWidget {
  const NotesOwner({required this.open, required this.builder, super.key});

  final Future<Result<Notes, NotesFailure>> Function() open;
  final Widget Function(BuildContext context, Notes notes) builder;

  @override
  State<NotesOwner> createState() => _NotesOwnerState();
}

final class _NotesOwnerState extends State<NotesOwner> {
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
    if (notes != null) return widget.builder(context, notes);
    final strings = AppLocalizations.of(context);
    return UiPage(
      title: strings.title,
      child: _opening
          ? const UiLoading()
          : UiColumn(
              children: [
                if (_failure != null) UiError(strings.unavailable),
                UiButton(label: strings.retry, onPressed: _open),
              ],
            ),
    );
  }
}
