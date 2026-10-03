# 0003: Separate typed failures, diagnostics, and localized UI

Status: Accepted for this template.

## Context

Technical exception messages are unsuitable user interfaces and may disclose sensitive data. Returning translated strings from a capability couples its behavior to a presentation context and makes locale changes difficult to handle correctly.

## Decision

Operations use the shared `Result<T, F>` mechanism with capability-owned failure types. The capability handles expected technical causes internally and reports safe diagnostic codes and type information through the diagnostic boundary. Two sinks ship with the template: `RedactedDiagnostics` emits only the code and exception type, and `DebugDiagnostics` emits the full exception and stack for a developer at the keyboard. The shell selects the debug sink only under `kDebugMode`, so no build that leaves the machine carries raw exception text. A redaction that developers must bypass with `print` protects less than one they can switch off locally.

Features map typed failures to their ARB messages at render time and select meaningful recovery actions. `ui_kit` provides the presentation components. The result package contains no application-wide catalog of domain failures, and capability failures contain no translation keys or user-facing prose.

## Consequences

One failure can receive appropriate wording and actions in different journeys. Diagnostic policy can evolve independently of UI wording. Callers must handle meaningful outcomes explicitly, including cancellation or uncertain completion when the operation requires them. Programming defects must not be silently recategorized as routine user failures.

## Verification

Capability tests verify failure mapping and safe diagnostic output. Feature tests verify localized messages and recovery actions without rendering raw exception content. A custom diagnostic sink requires its own sanitization tests; substitutability is not permission to log secrets.

## References

Sources consulted 2026-10-02: [Flutter's application-defined Result pattern](https://docs.flutter.dev/app-architecture/design-patterns/result), [Dart programming errors](https://api.dart.dev/dart-core/Error-class.html), [package-owned localization](https://docs.flutter.dev/ui/internationalization#loading-and-retrieving-localized-values), and [OWASP logging guidance](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html). `Result<T, F>` is this template's typed adaptation, not a built-in Dart type. The default diagnostic adapter intentionally logs only allowlisted metadata; an adapter that preserves richer developer detail must establish what can be safely recorded.
