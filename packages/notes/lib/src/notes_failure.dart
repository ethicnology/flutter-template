/// An expected failure that the presentation layer translates for its audience.
sealed class NotesFailure {
  const NotesFailure();
}

final class EmptyNote extends NotesFailure {
  const EmptyNote();
}

final class NoteTooLong extends NotesFailure {
  const NoteTooLong(this.maxLength);

  final int maxLength;
}

/// Storage is unavailable or this collection has been closed.
final class NotesUnavailable extends NotesFailure {
  const NotesUnavailable();
}
