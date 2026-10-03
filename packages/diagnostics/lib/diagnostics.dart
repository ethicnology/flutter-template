import 'dart:developer' as developer;

/// Receives technical diagnostics at their owning module's boundary.
/// Implementations must not let diagnostics failures break application work.
abstract interface class DiagnosticSink {
  void record(
    String code, {
    required Object error,
    required StackTrace stackTrace,
  });
}

/// Logs allowlisted metadata, never exception messages or application data.
/// Use it in release builds, or anywhere output may leave the device. The
/// original exception and stack remain available to another injected sink,
/// which must establish its own redaction policy before transmitting them.
final class RedactedDiagnostics implements DiagnosticSink {
  const RedactedDiagnostics();

  @override
  void record(
    String code, {
    required Object error,
    required StackTrace stackTrace,
  }) {
    developer.log(
      diagnosticSummary(code, error),
      name: 'app.diagnostics',
      level: 1000,
    );
  }
}

/// Logs the full exception and stack for a developer at the keyboard.
/// Exception messages can contain statements, paths or user data: never
/// select this sink in a build that leaves the development machine.
final class DebugDiagnostics implements DiagnosticSink {
  const DebugDiagnostics();

  @override
  void record(
    String code, {
    required Object error,
    required StackTrace stackTrace,
  }) {
    developer.log(
      diagnosticSummary(code, error),
      name: 'app.diagnostics',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// [code] must be a constant identifier, never user input.
String diagnosticSummary(String code, Object error) =>
    '$code (${error.runtimeType})';
