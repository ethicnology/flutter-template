# Result

Use `Result<T, F>` for expected operation outcomes. Each capability defines its own failure types. Consumers exhaustively switch on `case Success(:final value)` and `case Failure(:final failure)`; Dart infers the type arguments from the scrutinee, so spelling them out in a pattern only adds noise. Presentation code localizes the failure when rendering. This package has no exception, logging, UI, or localization dependencies.

Do not turn assertion failures or programming errors into successful operations or generic business failures. Translate infrastructure exceptions at the capability boundary where their meaning is known. Never put an exception message or a pretranslated user message in the shared result type.
