import 'dart:io';

import 'package:test/test.dart';

import '../tool/test_module.dart';

void main() {
  test(
    'an interrupted run is not a success even after individual tests pass',
    () {
      final report = TestReport()
        ..add({'type': 'testDone', 'result': 'success'});
      expect(report.succeeded, isFalse);
      report.add({'type': 'done', 'success': true});
      expect(report.succeeded, isTrue);
    },
  );
  test('an empty or skipped-only run is not verification', () {
    final report = TestReport()
      ..add({'type': 'testDone', 'result': 'success', 'skipped': true})
      ..add({'type': 'done', 'success': true});
    expect(report.succeeded, isFalse);
  });
  test('reported errors cannot be hidden by a successful done event', () {
    final report = TestReport()
      ..add({'type': 'testDone', 'result': 'success'})
      ..add({'type': 'error', 'error': 'Failure'})
      ..add({'type': 'done', 'success': true});
    expect(report.succeeded, isFalse);
  });

  test(
    'a reported error reaches stderr without crashing the reporter',
    () async {
      final run = await Process.run(Platform.resolvedExecutable, [
        'run',
        'tool/test_module.dart',
        'dart',
        'test/does_not_exist_test.dart',
      ]);
      expect(run.exitCode, 1);
      expect(run.stderr, isNot(contains('Bad state')));
      expect(run.stderr, contains('does_not_exist_test.dart'));
    },
  );
}
