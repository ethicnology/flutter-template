# 0001: Modules own their implementation and data

Status: Accepted for this template.

## Context

A module boundary fails to reduce consumer context when its callers must assemble internal repositories, database executors, or adapters. A shared schema also couples otherwise unrelated module changes and migrations.

## Decision

Each module owns the implementation required by its responsibility and exposes a small consumer-facing contract, including initialization and disposal. A module requiring local persistence owns its own SQLite/Drift database, schema, and migrations. Cross-module operations use public APIs; direct table access and shared database executors are prohibited.

The shell composes public feature entry points and owns application routing. It supplies application-level choices without implementing module adapters or managing each feature's capabilities. When one journey needs a capability, that journey owns it: `NoteCaptureFeature` opens and closes its `Notes` instance and presents localized initialization failures. When several journeys share it, the shell owns it: `NotesOwner` opens one handle through the public API, `NoteCaptureScreen` and `NoteReviewScreen` borrow it, and the owner closes it after both are gone. Borrowing screens never close a handle they did not open. A package need not be reusable across products or pure Dart to justify its boundary.

## Features never import features

A feature is the unit that can be deleted, rewritten or replaced alone. A feature that imports another one loses that property: the imported feature can no longer change its screens, state or strings without a two-feature change, one-way imports grow into a hierarchy nobody designed, and the importing feature's tests compile the other feature. An import between features almost always marks an extraction that has not happened: shared data or operations belong to a capability, shared visuals to the kit, a sequence of journeys to the shell.

Cross-journey navigation is the recurring case. The feature exposes a typed intent at its entry point and the shell wires it to a tab, a route or nothing: `NoteCaptureScreen.onReviewRequested` is wired by `AppHome` to the review tab, and left null by `NoteCaptureFeature`, which hides the control. This is the callback-injection pattern of Feature-First Clean Architecture: "a feature exposes typed callbacks at its entry point" and "the app layer wires those callbacks to real, type-safe routes". Android's modularization guide describes the same mediator role for the app module and recommends passing identifiers, not objects, between features.

The alternative chosen by Android's Navigation 3 guidance and Now in Android splits every feature into an `api` package holding its navigation keys and an `impl` package holding its screens: an `impl` may depend on another feature's `api`, never on its `impl`. It makes the target of a navigation explicit and lets each team own its keys, at the price of two packages per feature. Its build-time argument rests on Gradle's per-module incremental compilation and does not transfer to Dart, where the application is compiled as one program. Reach for it when several teams own features and must pass typed arguments to each other without the shell knowing their shape; until then, typed callbacks give the same compile-time safety with one package per feature.

Consumers can work against the contract without learning the storage implementation. Modules can evolve their internals independently within that contract. The owner must make resource lifetime and test substitution explicit.

An operation spanning independently owned database connections cannot assume a shared SQLite transaction. Such operations require explicit recovery and consistency semantics, or a revised responsibility boundary. SQLite can coordinate attached files under specific connection and journal conditions; this template does not use that mechanism to bypass module ownership. Separate databases do not remove logical coupling or provide an operating-system security boundary between packages.

A widget-owned handle, as `NotesOwner` shows, is correct only while every consumer is a screen. A capability that must work without a screen, such as background synchronization, needs an owner outside the widget tree with an explicit application lifetime; this template does not demonstrate that owner.

Use local structure before adding package boundaries: a feature can separate its screen, controller/state, and localization while keeping a single-consumer capability internal. Extract a package when it offers a useful independent contract. Storage and adapters remain implementation details behind the capability's public API, values, and failures. Additional domain layers, interfaces, and generators require a concrete justification.

## Verification

Architecture checks reject forbidden imports and dependencies, including unregistered nested workspace packages. Capability tests use public operations to verify persistence and draining close. Feature tests exercise initialization, retry, disposal and late completion. Shell tests exercise the shared owner: one open for two journeys, a write in one journey visible in the other, closure on disposal, and localized startup retry. Public signatures must be reviewed for leaked implementation types: the import checker does not prove that guarantee, and this template has no automated public-API surface check.

## References

Navigation sources, consulted 2026-10-05: [Feature-First Clean Architecture](https://verygood.ventures/blog/feature-first-clean-architecture/) for the callback-injection pattern; [Common modularization patterns](https://developer.android.com/topic/modularization/patterns) for the mediator module and identifier passing; [Modularize navigation code](https://developer.android.com/guide/navigation/navigation-3/modularize) and the [Now in Android learning journey](https://github.com/android/nowinandroid/blob/main/docs/ModularizationLearningJourney.md) for the api/impl split, with its motivation discussed in [Now in Android #2009](https://github.com/android/nowinandroid/discussions/2009).

Tooling sources, consulted 2026-10-02: [Dart Pub workspaces](https://dart.dev/tools/pub/workspaces), [Melos 8.9.0](https://pub.dev/packages/melos/versions/8.9.0), and the [Melos list command](https://melos.invertase.dev/commands/list). Pub supplies shared dependency resolution; Melos supplies workspace commands and Mermaid output. Module ownership remains an application contract.

Research on repository documentation for agents is summarized in [references](../references.md); none of it validates this Flutter structure.

Storage mechanisms: [Drift migration testing](https://drift.simonbinder.eu/migrations/tests/), [Drift isolates and independent instances](https://drift.simonbinder.eu/isolates/), and [SQLite ATTACH transaction conditions](https://sqlite.org/lang_attach.html). Separate storage per owning module and a shell that knows only public facades are explicit project policies, not requirements imposed by Flutter or Drift.
