# Diagnostics

Inject `DiagnosticSink` at a module's public entry point. The module records the original exception and stack with a constant operation code where it translates an infrastructure failure into a typed failure. The UI receives only the typed failure. Avoid duplicate logging at every layer.

`RedactedDiagnostics` deliberately emits only the code and exception type. Raw exceptions may contain database statements, note content, credentials, or paths; neither their messages nor their stack traces are emitted by this adapter. `DebugDiagnostics` emits the full exception and stack; select it only under `kDebugMode`, as the shell does, so it never leaves a development build. A production telemetry adapter belongs in this package or a dedicated diagnostics adapter package, never in the shell, and must explicitly redact before persistence or transmission. Sinks must not throw.
