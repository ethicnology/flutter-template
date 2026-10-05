# Result

Use `Result<T, F>` for expected operation outcomes. Each capability defines its own failure types. Consumers exhaustively switch on `case Success(:final value)` and `case Failure(:final failure)`; Dart infers the type arguments from the scrutinee, so spelling them out in a pattern only adds noise. Presentation code localizes the failure when rendering. This package has no exception, logging, UI, or localization dependencies.

Do not turn assertion failures or programming errors into successful operations or generic business failures. Translate infrastructure exceptions at the capability boundary where their meaning is known. Never put an exception message or a pretranslated user message in the shared result type.

## Why `Success` and `Failure`

Flutter's own Result example names its variants `Ok` and `Error`. This template does not, for two reasons. A class named `Error` imported from a package silently shadows `dart:core`'s `Error` in every file that imports it, with no analyzer warning: an `on Error catch` in such a file no longer matches a `StateError`, which is the kind of defect that only shows in production. And `Error` names exactly what this type must never carry, a programming error. `Success` and `Failure` also agree with the capability failure types and the `failure` field, so `Failure(NotesFailure)` reads as one sentence. `Ok` and `Err` would be the other consistent pair; adopting it means renaming the failure types and field with it.
