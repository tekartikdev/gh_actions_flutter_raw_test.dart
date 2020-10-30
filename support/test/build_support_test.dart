import 'dart:io';

import 'package:dev_test/package.dart';
import 'package:flutter_raw_test_support/build_support.dart';
import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';
import 'package:test/test.dart';

void main() {
  group('flutter test', () {
    var dir = join('.dart_tool', 'raw_flutter_test1', 'test', 'project');
    var _ensureCreated = false;
    var shell = Shell(workingDirectory: dir);
    Future<void> _create() async {
      await initFlutter();
      await flutterCreateProject(
        path: dir,
      );
    }

    Future<void> _ensureCreate() async {
      if (!_ensureCreated) {
        if (!Directory(dir).existsSync()) {
          await _create();
        }
        _ensureCreated = true;
      }
    }

    Future<void> _iosBuild() async {
      if (supportsIOS) {
        await shell.run('flutter build ios --release --no-codesign');
      }
    }

    Future<void> _androidBuild() async {
      if (supportsAndroid) {
        await shell.run('flutter build apk');
      }
    }

    test('create', () async {
      await initFlutter();
      await flutterCreateProject(
        path: dir,
      );
      await packageRunCi(dir);
    });
    test('build ios', () async {
      await _ensureCreate();
      await _iosBuild();
    }, timeout: Timeout(Duration(minutes: 5)));

    test('build android', () async {
      await _ensureCreate();
      await _androidBuild();
    }, timeout: Timeout(Duration(minutes: 5)));
    test('add sqflite', () async {
      await _ensureCreate();
      if (await addDependency(dir, 'sqflite')) {
        await _iosBuild();
        await _androidBuild();
      }
    }, timeout: Timeout(Duration(minutes: 5)));
  });
}
