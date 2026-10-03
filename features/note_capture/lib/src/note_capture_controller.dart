import 'package:flutter/foundation.dart';
import 'package:notes/notes.dart';
import 'package:result/result.dart';

import 'note_capture_state.dart';

/// Orchestrates draft submission without depending on widgets or strings.
/// The collection belongs to the caller; disposing this controller does not
/// close it. The list is observed by the screen through `Notes.watch`.
final class NoteCaptureController extends ChangeNotifier {
  NoteCaptureController(this._notes);

  final Notes _notes;
  Submission _submission = const Idle();
  bool _disposed = false;
  int _inputRevision = 0;

  Submission get submission => _submission;
  int get inputRevision => _inputRevision;

  /// Returns whether a write succeeded while this controller was still active.
  /// Pending writes are not cancelled by disposal: the storage contract has no
  /// cancellation. Their late results are simply ignored by this presentation.
  Future<bool> save(String text) async {
    if (_disposed || _submission is Submitting) return false;
    final submittedRevision = _inputRevision;
    _update(const Submitting());
    final outcome = await _notes.add(text);
    if (_disposed) return false;
    final draftUnchanged = submittedRevision == _inputRevision;
    switch (outcome) {
      case Success():
        _update(draftUnchanged ? const Submitted() : const Idle());
        return true;
      case Failure(:final failure):
        // Field validation describes the submitted draft, while an operational
        // failure remains relevant even after the user edits that draft.
        _update(
          draftUnchanged || failure is NotesUnavailable
              ? Rejected(failure)
              : const Idle(),
        );
        return false;
    }
  }

  void inputChanged() {
    if (_disposed) return;
    _inputRevision++;
    if (_submission case Submitted() || Rejected()) _update(const Idle());
  }

  void _update(Submission value) {
    _submission = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
