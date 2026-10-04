# Working in this template

Read the relevant module's README and public library before editing it. Consult `architecture.md` when changing a module boundary; read linked decisions only when the task needs their rationale. Do not load every module or generated source by default.

Use the Flutter version in `.fvmrc` and the root lockfile. Run commands from the workspace root unless targeting one module. `dart run melos run` lists supported tasks. Run a module's tests while editing; run `dart run melos run verify` after integrating code changes. Documentation-only changes do not require application tests.

Generated sources are not committed; run `dart run melos run prepare` in a fresh clone. Modify generator inputs, then run `dart run melos run generate`, and never edit generated output. Import other modules through public libraries. Features never import Material or Cupertino: when a feature needs a visual component the kit lacks, add it to `ui_kit` in the same change, with a Widgetbook case and a widget test, rather than composing Material locally. `UiPage` is the only screen structure. A local collection exposes `watch()`; a remote service is queried. Widget tests over storage use `notes_testing`. Keep diagnostics free of user data. Do not duplicate these rules into module instruction files.
