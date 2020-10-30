import 'dart:io';

import 'package:dev_test/src/mixin/package.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:process_run/dartbin.dart';
import 'package:process_run/shell_run.dart';
import 'package:process_run/which.dart';

/// Returns true if added
Future<bool> addDependency(String dir, String dependency,
    {String dependencyLine}) async {
  var map = await pathGetPubspecYamlMap(dir);
  if (!pubspecYamlHasAnyDependencies(map, [dependency])) {
    var file = await File(join(dir, 'pubspec.yaml'));
    var content = await file.readAsString();
    content =
        pubspecStringAddDependecy(content, dependencyLine ?? '$dependency:');
    await file.writeAsString(content);
    return true;
  }
  return false;
}

/// Add a dependency in a brut force way
///
String pubspecStringAddDependecy(String content, String dependencyLine) {
  return content.replaceAllMapped(RegExp(r'^dependencies:$', multiLine: true),
      (match) => 'dependencies:\n  $dependencyLine');
}

String _flutterChannel;
Future initFlutter() async {
  _flutterChannel = await getFlutterBinChannel();
  if (supportsMacOS) {
    await run('flutter config --enable-macos-desktop');
  }
  if (supportsLinux) {
    await run('flutter config --enable-linux-desktop');
  }
  if (supportsWindows) {
    await run('flutter config --enable-windows-desktop');
  }
}

bool get supportsMacOS =>
    Platform.isMacOS &&
    [dartChannelDev, dartChannelMaster].contains(_flutterChannel);

bool _supportsIOS;

/// For now based on x-code presence.
bool get supportsIOS =>
    _supportsIOS ??= Platform.isMacOS && whichSync('xcode-select') != null;

bool _supportsAndroid;

/// Always allowed for now
bool get supportsAndroid => _supportsAndroid ??= true;

bool get supportsLinux =>
    Platform.isLinux &&
    [dartChannelDev, dartChannelMaster].contains(_flutterChannel);

bool get supportsWindows =>
    Platform.isWindows && [dartChannelMaster].contains(_flutterChannel);

extension _DirectoryExt on Directory {
  /// Create if needed
  Future<void> prepare() async {
    if (await exists()) {
      try {
        await delete(recursive: true);
      } catch (_) {}
    }
    await parent.create(recursive: true);
  }
}

const dartTemplateConsoleSimple = 'console-simple';
const flutterTemplateApp = 'app';

Future<void> dartCreateProject(
    {@required String template, @required String path}) async {
  await Directory(path).prepare();

  var shell = Shell().cd(dirname(path));
  await shell
      .run('dart create --template $template ${shellArgument(basename(path))}');
}

Future<void> flutterCreateProject({
  @required String path,
  String template = flutterTemplateApp,
  bool noAnalyze,
}) async {
  await Directory(path).prepare();

  var shell = Shell().cd(dirname(path));

  await shell.run(
      'flutter create --template $template ${shellArgument(basename(path))}');
}
