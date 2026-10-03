# Modular Flutter template

A small executable starting point for applications built from autonomous modules. The shell composes features; each capability owns its implementation and storage; features compose a shared UI kit. Widgetbook exposes that kit independently.

Start with the [architecture map](architecture.md), or go directly to the module relevant to your task. Detailed decision records are optional reading, not a mandatory context bundle.

## Toolchain

The template targets Flutter **3.47.6** (stable, released 2026-10-01), pinned in `.fvmrc`. Use that SDK on your PATH, or prefix Flutter/Dart commands with your existing SDK manager. No global Melos installation is required. The root `pubspec.lock` is part of the template and must remain versioned.

Direct tools use stable releases available on 2026-10-02: Melos 8.9.0, Widgetbook 3.25.0, Drift 2.35.1, and build_runner 2.16.1. Manifests declare caret ranges; the versioned `pubspec.lock` with `--enforce-lockfile` is what pins them, so an upgrade touches one file. “Latest” means the latest compatible stable set: Flutter pins test_api 0.7.12, requiring test 1.31.1, which in turn limits analyzer to 13.3.0. Do not override SDK pins to force newer incompatible test tools. Review upgrades deliberately and regenerate the lockfile.

## Start

```sh
flutter pub get --enforce-lockfile
dart run melos run prepare
dart run melos run catalog
```

The catalog runs in Chrome. To run the example application on a configured native device, use `dart run melos run app`. The native app stores notes locally; the catalog does not initialize the notes module. Platform SDKs and a browser are external prerequisites, not installed by these commands.

## Workspace

| Module | Consumer contract |
| --- | --- |
| [Application shell](apps/app/README.md) | Composition and product-level configuration |
| [Widgetbook](packages/ui_kit/example/README.md) | Isolated component states and themes, alongside the kit |
| [Note capture](features/note_capture/README.md) | Localized interaction and feature lifetime |
| [Note review](features/note_review/README.md) | Read-only observation of a borrowed collection |
| [Notes](packages/notes/README.md) | Validated operations, observable snapshots and private SQLite persistence |
| [Notes testing](packages/notes_testing/README.md) | Widget-test helpers over real storage |
| [UI kit](packages/ui_kit/README.md) | Shared visual components and adaptive layout |
| [Result](packages/result/README.md) | Typed success and failure values |
| [Diagnostics](packages/diagnostics/README.md) | Debug and redacted developer diagnostics |

See the [generated dependency diagram](docs/module-graph.md). The two note journeys are replaceable examples, not required capabilities in projects created from this template. Together they show the shared-capability case: the shell opens one `Notes` handle, both journeys borrow it, and the shell closes it after they are gone.

## Work on one module

Run `flutter test` from a Flutter module or `dart test` from a pure Dart module. Read its public entry point and README; inspect a dependency's internals only when the task requires changing that dependency. A feature may own private capability code without extracting another package when no useful independent contract exists.

Root commands are listed by `dart run melos run`:

| Script | Effect |
| --- | --- |
| `prepare` | Resolve locked dependencies and generate translations/database code |
| `generate` | Run generators serially in their owning modules |
| `analyze` | Generate sources and analyze the workspace |
| `test` | Generate sources, then run tooling and module tests |
| `architecture` | Check metadata, declared dependency rules, cycles and Dart imports |
| `graph` | Refresh the Mermaid diagram using Melos |
| `verify` | Generate once, then check boundaries, graph, formatting, analysis and tests |

Generation and verification are intentionally explicit. Incremental source fingerprints and affected-only CI are not enabled in this starter: global configuration changes and external generator inputs need a defined invalidation policy first. A green command must represent the tests intended to run.

Workspace scripts disable interactive package selection, so `dart run melos run verify` checks every eligible module. Use explicit package filters or run tests from one module when you intentionally want a narrower check. Widgetbook is a separate application package under `ui_kit/example`: it depends on the kit, and the kit never depends on the catalog.

## Add or change a module

Create a real Dart/Flutter package under `features/` or `packages/`, add `resolution: workspace`, and list it in the root `workspace`. Define its responsibility, role, storage ownership and allowed local dependencies in `module.yaml`. Export its consumer-facing types from a public library; keep implementation in `lib/src`.

Add a short README with a consumer example and lifecycle/error guarantees. Keep a feature's screens, controller/state, translations and tests together. Put reusable visual primitives in `ui_kit` and add their Widgetbook states. Regenerate the graph and run the relevant checks. The checker inspects runtime imports/exports, including conditional imports; it cannot prove resource ownership, business invariants, accessibility, or cross-database consistency.

## Customize before shipping

Replace the sample capability and product description. Rename native identifiers, display names and icons; configure signing and supported platforms. The shell's bottom navigation is the minimal routing for two journeys; replace it with real routing and deep links when the product needs them, keeping ownership of app-scoped capabilities in the shell as `NotesOwner` demonstrates. Do not treat the sample as a production security, synchronization, backup or release implementation.

The included runners target Android, iOS and macOS. The notes backend is native-only; Widgetbook has a separate web target. Native platform builds, device behavior and release signing require their own validation. The GitHub workflow is prepared for a future repository; no workflow has been run remotely.

## License

The template is released under the [MIT License](LICENSE). Projects created from it may choose any license.
