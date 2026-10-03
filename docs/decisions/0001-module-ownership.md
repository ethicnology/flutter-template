# 0001: Modules own their implementation and data

Status: Accepted for this template.

## Context

A module boundary fails to reduce consumer context when its callers must assemble internal repositories, database executors, or adapters. A shared schema also couples otherwise unrelated module changes and migrations.

## Decision

Each module owns the implementation required by its responsibility and exposes a small consumer-facing contract, including initialization and disposal. A module requiring local persistence owns its own SQLite/Drift database, schema, and migrations. Cross-module operations use public APIs; direct table access and shared database executors are prohibited.

The shell composes public feature entry points and owns application routing. It supplies application-level choices without implementing module adapters or managing each feature's capabilities. When one journey needs a capability, that journey owns it: `NoteCaptureFeature` opens and closes its `Notes` instance and presents localized initialization failures. When several journeys share it, the shell owns it: `NotesOwner` opens one handle through the public API, `NoteCaptureScreen` and `NoteReviewScreen` borrow it, and the owner closes it after both are gone. Borrowing screens never close a handle they did not open. A package need not be reusable across products or pure Dart to justify its boundary.

## Consequences

Consumers can work against the contract without learning the storage implementation. Modules can evolve their internals independently within that contract. The owner must make resource lifetime and test substitution explicit.

An operation spanning independently owned database connections cannot assume a shared SQLite transaction. Such operations require explicit recovery and consistency semantics, or a revised responsibility boundary. SQLite can coordinate attached files under specific connection and journal conditions; this template does not use that mechanism to bypass module ownership. Separate databases do not remove logical coupling or provide an operating-system security boundary between packages.

A widget-owned handle, as `NotesOwner` shows, is correct only while every consumer is a screen. A capability that must work without a screen, such as background synchronization, needs an owner outside the widget tree with an explicit application lifetime; this template does not demonstrate that owner.

Use local structure before adding package boundaries: a feature can separate its screen, controller/state, and localization while keeping a single-consumer capability internal. Extract a package when it offers a useful independent contract. Storage and adapters remain implementation details behind the capability's public API, values, and failures. Additional domain layers, interfaces, and generators require a concrete justification.

## Verification

Architecture checks reject forbidden imports and dependencies, including unregistered nested workspace packages. Capability tests use public operations to verify persistence and draining close. Feature tests exercise initialization, retry, disposal and late completion. Shell tests exercise the shared owner: one open for two journeys, a write in one journey visible in the other, closure on disposal, and localized startup retry. Public signatures must be reviewed for leaked implementation types: the import checker does not prove that guarantee, and this template has no automated public-API surface check.

## References

Tooling sources, consulted 2026-10-02: [Dart Pub workspaces](https://dart.dev/tools/pub/workspaces), [Melos 8.9.0](https://pub.dev/packages/melos/versions/8.9.0), and the [Melos list command](https://melos.invertase.dev/commands/list). Pub supplies shared dependency resolution; Melos supplies workspace commands and Mermaid output. Module ownership remains an application contract.

Research on repository documentation for agents is summarized in [references](../references.md); none of it validates this Flutter structure.

Storage mechanisms: [Drift migration testing](https://drift.simonbinder.eu/migrations/tests/), [Drift isolates and independent instances](https://drift.simonbinder.eu/isolates/), and [SQLite ATTACH transaction conditions](https://sqlite.org/lang_attach.html). Separate storage per owning module and a shell that knows only public facades are explicit project policies, not requirements imposed by Flutter or Drift.
