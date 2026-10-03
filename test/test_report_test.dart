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
}
