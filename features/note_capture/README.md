# Note capture

A complete small journey for writing and reviewing local notes. It owns presentation state, English/French messages, loading and failure states, and collection lifecycle when entered through `NoteCaptureFeature`. It consumes only the public `notes` API and shared `ui_kit` visual components.

## Integrate

```dart
UiKitApp(
  title: 'Notes',
  supportedLocales: NoteCaptureLocalizations.supportedLocales,
  localizationsDelegates: [NoteCaptureLocalizations.delegate],
  home: NoteCaptureFeature(diagnostics: diagnostics),
)
```

The shell contributes the route and diagnostic policy. It does not construct SQLite, Drift, repositories, or storage-error mappings. `NoteCaptureFeature` opens storage, renders a localized retry on initialization failure, closes its collection on disposal, and closes late initialization results if its route has already disappeared.

`NoteCaptureFeature` is the entry point when this is the only journey that needs notes. It requires a single concurrently mounted instance for the default database; it does not enforce a process-wide singleton. When several journeys share notes, as the application shell does with `note_review`, their common owner opens one `Notes` handle and passes it to `NoteCaptureScreen(notes: notes)`; that owner waits for all consumers to stop and then awaits `close()`. For tests or embedded demonstrations, the same borrowed screen accepts `Notes.inMemory`. Replacing its collection resets the list and discards results from the previous collection.

## State and failures

`NoteCaptureController` orchestrates draft submission and publishes a `Submission`, a sealed union with four exclusive forms: idle, submitting, submitted, or rejected with a typed failure. The list is not controller state: the screen observes `Notes.watch()` and renders the latest emission. Both controller and union are internal. The screen owns its text controller and maps state to shared visual components; it contains no storage calls or collection orchestration. Controller disposal ignores late results without pretending to cancel a write already accepted by storage.

Successful writes reach the list through the observed stream, in this screen and in any other journey observing the same collection. Failed writes retain the user's input. Every editing event advances a draft revision, so input edited during an in-flight save is retained even if its text returns to the submitted value. Late validation applies only to the submitted revision; storage failures remain visible. Save buttons prevent duplicate submissions while busy. When the stream ends on a storage failure, the retry action observes again.

Failures remain `NotesFailure` values until rendering. Validation failures appear beside the input; storage failures show safe localized text. Changing locale re-renders existing failures using the new locale. Technical exception messages never become UI strings, and this feature does not log failures already recorded by the storage owner.

## Localization and verification

ARB resources live in `lib/src/l10n`; `flutter gen-l10n` generates `NoteCaptureLocalizations` according to `l10n.yaml`. The library exports its delegate and supported locales for composition. English identifiers and prose remain separate from French translations.

Widget tests go through `notes_testing` over real in-memory SQLite, verify persisted writes, a write from another journey appearing in the list, localization after a locale change, and unavailable storage with retry. Controller tests cover duplicate-submission prevention, revision-aware pending results, operational failures, and disposal during an accepted write. A widget regression covers edits that return to the submitted text. Lifecycle tests exercise the internal opening boundary with public `Notes` handles: initialization failure, retry, acquired-handle disposal, and cleanup of a late opening result. They do not exercise the platform directory plugin; the production wrapper delegates to `Notes.open`. This native-storage sample does not claim web support.
