# Architecture

This template demonstrates autonomous Flutter modules with small public contracts. Read the map and applicable rules first; open a module README or decision only when the task involves it. Module consumers should not need to inspect implementation details.

## Scope and customization

**Customize:** State the product purpose, supported platforms, external systems, and critical invariants. Replace the note example with precisely named capabilities. Avoid modules named after the whole application or unspecified `core`, `common`, and `utils` collections.

The example implements note capture and review over one shared collection, private Drift storage, typed outcomes, localized failures, shared UI, and a Widgetbook catalog. Production routing, deep links, authentication, network synchronization, cross-module transactions, and native release configuration remain product-specific work. Workspace checks do not establish readiness on every platform.

## Module map

A package is a Dart unit; a feature is an architectural role. Features are Flutter packages. Capability packages can also depend on Flutter for platform integration; `packages/` does not mean pure Dart.

| Location | Responsibility |
| --- | --- |
| `apps/app` | Compose feature entry points and application configuration; own global navigation and the shared `Notes` handle. |
| `packages/ui_kit/example` | Review shared component states in a separate Widgetbook application beside the kit. |
| `features/note_capture` | Own the capture journey, optional capability lifecycle, and localized outcomes. |
| `features/note_review` | Own the read-only review journey that observes a borrowed collection. |
| `packages/notes` | Own note operations, observable snapshots, public values/failures, and private Drift persistence. |
| `packages/notes_testing` | Drive widget tests over real storage without fake-zone deadlocks. |
| `packages/ui_kit` | Own shared widgets, themes, adaptive behavior, and reusable accessibility behavior. |
| `packages/result` | Provide `Result<T, F>`, `Success.value`, and `Failure.failure`. |
| `packages/diagnostics` | Provide the safe diagnostic reporting contract. |

## Boundaries

The shell composes public features and passes application-level choices. It does not implement adapters or construct databases, DAOs, repositories, or platform clients. Features own internal navigation and interaction state, and consume capability contracts and `ui_kit`; they do not import other features. Capabilities do not import features or shells. Shared UI does not depend on features or application capabilities.

A local collection is observable: its contract exposes `watch()` and consumers render the latest emission instead of keeping a copy. A remote service is queried, with any cache made explicit by its owner. Keep package dependencies acyclic and import public libraries only. Never import another package's `src`, cross its filesystem boundary with relative imports, or expose persistence types through public signatures. Do not introduce interfaces or a state-management framework without a concrete need.

Each module owns its implementation and resources. If it requires persistence, it owns a separate database, schema, and migrations. Access another owner's data through its contract, never its tables. Cross-database operations need explicit consistency and recovery semantics; reconsider boundaries when an invariant requires constant atomic coordination. See [ownership decision](docs/decisions/0001-module-ownership.md).

Resource lifetime follows its consumers: a route can own a capability used only by that route; several journeys need one shared owner for the capability's declared lifetime. Compose that owner's public API in the shell without constructing its private adapters. Separate files are an encapsulation policy, not a security boundary between packages in the same process.

## Inside a module

A feature separates screen rendering, controller/state, and localization as complexity warrants; `note_capture` demonstrates this separation. A state with exclusive forms is a sealed union, never a set of booleans: `Submission` in `note_capture` is idle, submitting, submitted or rejected, and the analyzer rejects a rendering that forgets one. A capability exposes its public API, values, and failures through a public library, with storage and adapters private. Do not mandate a use-case/repository/service/data-source hierarchy, an interface per class, or code generation for every package. A capability serving one feature can remain inside it; extraction requires a useful independent contract, not a package-count target.

## Consumer contract and runtime

Each module README explains purpose, when to use it, a minimal realistic example, owned and borrowed resources, lifecycle, failures, guarantees, and verification. Start a new module design with that consumer example. Split responsibilities when callers can work against a meaningful contract, rather than splitting mechanically by processing steps.

The shell composes `UiKitApp` with every feature's localization delegates and its own. Because two journeys share the notes collection, the shell owns the handle: `NotesOwner` calls the public `Notes.open`, presents a localized startup failure with retry, builds `AppHome` with the open handle, and closes it on disposal after both journeys are gone. `AppHome` switches between `NoteCaptureScreen` and `NoteReviewScreen` through `UiNavigation`; only the selected journey is mounted, and each observes the collection, so a note captured in one journey is already visible in the other. The shell constructs no database, DAO, or adapter: it only calls the capability's public API.

`NoteCaptureFeature` remains the single-journey entry point: it opens and closes its own collection, for products where only one route needs notes. `NoteCaptureScreen` and `NoteReviewScreen` borrow an existing `Notes` instance; their caller owns disposal.

The feature collects input through `ui_kit`, calls note operations, renders their typed outcomes, and observes the collection through `watch()` instead of maintaining its own list. The capability performs persistence internally. This separation lets consumers work without knowing Drift or the database layout.

## Errors and presentation

Capabilities own their typed failures; the result package owns only the success/failure mechanism. Original technical exceptions stay inside the implementation. `RedactedDiagnostics` reports safe codes and type information, not raw exception text or sensitive payloads; `DebugDiagnostics` reports everything and never leaves a debug build. The shell selects one with `kDebugMode`. Avoid duplicate logging. A custom sink needs an explicit sanitization policy.

Features resolve their ARB translations at render time, choose recovery actions, and present outcomes through `ui_kit`. The shell owns its own ARB resources for product-level strings: navigation labels and the startup failure it presents as the owner of the shared collection. Domain failures contain neither translated prose nor translation keys. Never render exception text. Associate field validation with the submitted input revision so late results do not overwrite newer edits. Model cancellation and uncertain completion explicitly when relevant. See [failure decision](docs/decisions/0003-failure-presentation.md).

Material and Cupertino imports belong inside `ui_kit`, not features or the shell; structural primitives come from `package:flutter/widgets.dart` directly, which the kit does not re-export. The kit owns the whole screen structure: `UiPage` is the only scaffold, and `UiNavigation` contributes a slot to it rather than wrapping it. A feature that needs a missing component extends the kit in the same change. Components carry a product decision, such as `UiText` roles mapped to the type scale, or they do not belong in the kit. Features retain responsibility for meaningful content, localized labels, and journey accessibility. Use Widgetbook for representative component states and widget tests for behavior; the catalog is not a correctness oracle. See [presentation decision](docs/decisions/0002-shared-presentation.md).

## Tooling and evidence

Dart Pub workspaces share dependency resolution. Melos 8.9.0 coordinates commands without a global installation; run `dart run melos run <script>`. The root README documents `prepare`, `generate`, `analyze`, `test`, `graph`, and `verify`.

`graph` wraps Melos `list --mermaid`. It shows declared dependencies without enriching them from metadata. A separate architecture checker reads `module.yaml` fields `role`, `responsibility`, `storage`, and `allowed_dependencies` and validates supported manifest/import rules. Neither the graph nor import checks prove runtime ownership, disposal, or transaction semantics.

Run focused checks during development and combined verification after integration. Capability tests cover behavior and persistence; feature tests cover transitions and localization through `notes_testing`, which keeps real SQLite work in the real async zone; kit tests cover shared presentation. Integration tests verify composition and lifecycle. Link important invariants to their tests or explicit review requirements, and update documentation alongside public contracts. Read the [ownership decision](docs/decisions/0001-module-ownership.md#references) for current tooling sources and the limits of evidence about agent context.
