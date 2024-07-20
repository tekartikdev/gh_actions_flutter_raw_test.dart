import 'package:dev_build/build_support.dart';

export 'package:dev_build/build_support.dart';

/// Returns true if added
Future<bool> addDependency(String dir, String dependency,
        {String? dependencyLine}) =>
    pathPubspecAddDependency(dir, dependency,
        dependencyLines: dependencyLine == null ? null : [dependencyLine]);

Future initFlutter() => buildInitFlutter();

bool get supportsMacOS => buildSupportsMacOS;

/// For now based on x-code presence.
bool get supportsIOS => buildSupportsIOS;

/// Always allowed for now
bool get supportsAndroid => buildSupportsAndroid;

bool get supportsLinux => buildSupportsLinux;

bool get supportsWindows => buildSupportsWindows;
