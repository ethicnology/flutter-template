# Application shell

`main.dart` composes the UI kit, the shell's and every feature's localization delegates, the shared notes owner, global navigation, and the diagnostic sink: full exceptions under `kDebugMode`, redacted codes otherwise. No database, repository implementation, or failure-to-message mapping belongs here.

## Shared capability ownership

Two journeys use the same notes collection, so neither can own it. `NotesOwner` opens one handle through the public `Notes.open`, shows a localized loading, failure and retry state while no handle exists, hands the open handle to `AppHome`, and closes it on disposal after the journeys that borrowed it are gone. A handle that opens after the owner was disposed is closed immediately. `AppHome` mounts only the selected journey; each journey observes the collection, so a note captured in one is already visible when the other is entered. It also wires the capture journey's `onReviewRequested` intent to the review tab: the shell is the only place where two journeys meet, and features never import one another. Nothing here constructs SQLite, Drift, or adapters.

`TemplateApp` accepts an opener and a locale so tests compose the real journeys over `Notes.inMemory` without the platform directory plugin. `test/template_app_test.dart` verifies a single open shared by both journeys, cross-journey visibility of a write, closure on disposal, and the localized startup retry. Those tests use `notes_testing`, which keeps storage work in the real async zone and unmounts the tree before closing; without it, a `close()` created in the fake zone would hang `tearDown` with no message. A third test asserts that every feature supports each locale the shell offers.

## Customize

The included Android, iOS, and macOS runners use placeholder identifiers under `dev.example`. Customize identifiers, display names, permissions, signing, icons, and release configuration before distribution. The notes example uses native SQLite; web storage is not implemented. Widgetbook has its own independent web runner.

Product-level strings live in `lib/l10n`. The bottom navigation is the minimal routing for two journeys; replace it with real routing and deep links when the product needs them, and keep internal feature navigation within its owner.
