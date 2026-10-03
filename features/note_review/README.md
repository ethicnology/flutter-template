# Note review

A read-only journey that observes the notes collection and shows a count and the list, with localized English/French states. It demonstrates a feature that **borrows** a capability owned elsewhere: it consumes the public `notes` API and shared `ui_kit` components, and never opens or closes storage.

## Integrate

```dart
NoteReviewScreen(notes: notes)
```

The caller owns the `Notes` handle for the lifetime of every journey that borrows it, and awaits `close()` only after those journeys are gone. The application shell shows the shared-owner composition alongside `note_capture`; tests pass `Notes.inMemory`.

## State and failures

The screen observes `Notes.watch()` and renders the latest emission, so writes made by another journey appear without any action. It observes again when it receives a different collection. A storage failure ends the stream with a typed `NotesFailure`, rendered as safe localized text with a retry action that observes again; the storage owner records the diagnostic, so this feature does not log it again.

## Localization and verification

ARB resources live in `lib/src/l10n`; `flutter gen-l10n` generates `NoteReviewLocalizations` according to `l10n.yaml`, including the ICU plural used for the count. Widget tests go through `notes_testing` over real in-memory SQLite and verify the newest-first list, an external write appearing without refresh, that disposal leaves the borrowed collection open, and the localized unavailable state.
