import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../tool/check_architecture.dart';

void main() {
  late Directory root;
  setUp(() {
    root = Directory.systemTemp.createTempSync('module-boundaries-');
    File(p.join(root.path, 'pubspec.yaml'))
        .writeAsStringSync('workspace: [packages/a, packages/b]\n');
    for (final name in ['a', 'b']) {
      final dir = Directory(p.join(root.path, 'packages', name, 'lib'))
        ..createSync(recursive: true);
      File(p.join(dir.parent.path, 'pubspec.yaml')).writeAsStringSync(
        'name: $name\nresolution: workspace\ndependencies: {}\n',
      );
      File(p.join(dir.parent.path, 'module.yaml')).writeAsStringSync(
        'role: capability\nresponsibility: Fixture\nstorage: none\nallowed_dependencies: [${name == 'a' ? 'b' : 'a'}]\n',
      );
      File(p.join(dir.path, '$name.dart'))
          .writeAsStringSync('const value = 1;\n');
    }
  });
  tearDown(() => root.deleteSync(recursive: true));
  test(
    'accepts independent modules',
    () => expect(checkArchitecture(root), isEmpty),
  );
  test('rejects an undeclared nested example package', () {
    Directory(p.join(root.path, 'packages/a'))
        .renameSync(p.join(root.path, 'packages/ui_kit'));
    File(p.join(root.path, 'pubspec.yaml'))
        .writeAsStringSync('workspace: [packages/ui_kit, packages/b]\n');
    final example = Directory(p.join(root.path, 'packages/ui_kit/example'))
      ..createSync();
    File(p.join(example.path, 'pubspec.yaml'))
        .writeAsStringSync('name: ui_kit_example\n');

    expect(checkArchitecture(root), [
      '${example.path}: package missing from workspace',
    ]);
  });
  test('accepts an explicitly declared nested package', () {
    final example = Directory(p.join(root.path, 'packages/a/example'))
      ..createSync();
    File(p.join(example.path, 'pubspec.yaml')).writeAsStringSync(
      'name: example\nresolution: workspace\ndependencies: {}\n',
    );
    File(p.join(example.path, 'module.yaml')).writeAsStringSync(
      'role: catalog\nresponsibility: Fixture\nstorage: none\n',
    );
    File(p.join(root.path, 'pubspec.yaml')).writeAsStringSync(
      'workspace: [packages/a, packages/b, packages/a/example]\n',
    );

    expect(checkArchitecture(root), isEmpty);
  });
  test('ignores packages inside generated and tool-owned trees', () {
    for (final name in ['.dart_tool', 'build', '.git', '.fvm']) {
      final generated = Directory(
        p.join(root.path, 'packages/a', name, 'nested/package'),
      )..createSync(recursive: true);
      File(p.join(generated.path, 'pubspec.yaml'))
          .writeAsStringSync('name: generated_package\n');
    }

    expect(checkArchitecture(root), isEmpty);
  });
  test('rejects cross-package private imports even in a conditional branch', () {
    File(p.join(root.path, 'packages/a/lib/a.dart')).writeAsStringSync(
      "import 'dart:io' if (dart.library.html) 'package:b/src/private.dart';\n",
    );
    expect(checkArchitecture(root), contains(contains('private import')));
  });
  test('rejects relative escapes', () {
    File(p.join(root.path, 'packages/a/lib/a.dart'))
        .writeAsStringSync("export '../../b/lib/b.dart';\n");
    expect(checkArchitecture(root), contains(contains('escapes module')));
  });
  test('rejects dependency cycles', () {
    for (final name in ['a', 'b']) {
      File(p.join(root.path, 'packages/$name/pubspec.yaml')).writeAsStringSync(
        'name: $name\nresolution: workspace\ndependencies:\n  ${name == 'a' ? 'b' : 'a'}: any\n',
      );
    }
    expect(checkArchitecture(root), contains(contains('cycle')));
  });
}
