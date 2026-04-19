import 'dart:io';

import 'package:dev_build/package.dart';
import 'package:flutter_raw_test_support/build_support.dart';
import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';
import 'package:test/test.dart';

Future<T> msTimed<T>(Future<T> Function() action, {String? tag}) async {
  var stopwatch = Stopwatch()..start();
  var result = await action();
  stopwatch.stop();
  stdout.writeln('${tag ?? 'timed'}: ${stopwatch.elapsedMilliseconds} ms');
  return result;
}

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
      await msTimed(() async {
        await initFlutter();
        await flutterCreateProject(
          path: dir,
        );
        await packageRunCi(dir);
      }, tag: 'create and run_ci');
    }, timeout: Timeout(Duration(minutes: 5)));
    test('run_ci', () async {
      await _ensureCreate();
      await msTimed(() async {
        await packageRunCi(dir);
      }, tag: 'run_ci');
    }, timeout: Timeout(Duration(minutes: 5)));

    test('build ios', () async {
      await _ensureCreate();
      await msTimed(() async {
        await _iosBuild();
      }, tag: 'build ios');
    }, timeout: Timeout(Duration(minutes: 5)));

    test('build android', () async {
      await _ensureCreate();
      await msTimed(() async {
        await _androidBuild();
      }, tag: 'build android');
    }, timeout: Timeout(Duration(minutes: 5)));
    test('add sqflite', () async {
      await _ensureCreate();
      await msTimed(() async {
        if (await addDependency(dir, 'sqflite')) {
          await _iosBuild();
          await _androidBuild();
          await packageRunCi(dir);
        }
      }, tag: 'add sqflite ios/android build and ci');
    }, timeout: Timeout(Duration(minutes: 10)));
  });
}
