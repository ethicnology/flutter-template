import 'package:notes/notes.dart';

/// The exclusive states of the draft submission. Failures stay typed until
/// presentation renders them. The list itself comes from `Notes.watch`.
sealed class Submission {
  const Submission();
}

final class Idle extends Submission {
  const Idle();
}

final class Submitting extends Submission {
  const Submitting();
}

/// The draft that was submitted is the one still in the field.
final class Submitted extends Submission {
  const Submitted();
}

final class Rejected extends Submission {
  const Rejected(this.failure);

  final NotesFailure failure;
}
