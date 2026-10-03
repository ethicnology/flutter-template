import 'package:diagnostics/diagnostics.dart';
import 'package:test/test.dart';

void main() {
  test('default diagnostics never format the exception payload', () {
    final error = _SensitiveError();
    expect(
      diagnosticSummary('notes.write_failed', error),
      'notes.write_failed (_SensitiveError)',
    );
    expect(error.formatted, isFalse);
  });

  test('the redacted sink never formats the exception payload', () {
    final error = _SensitiveError();
    const RedactedDiagnostics().record(
      'notes.write_failed',
      error: error,
      stackTrace: StackTrace.empty,
    );
    expect(error.formatted, isFalse);
  });
}

class _SensitiveError implements Exception {
  bool formatted = false;

  @override
  String toString() {
    formatted = true;
    return 'private note contents';
  }
}
