import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';

Future<void> main() async {
  var dir = join('.dart_tool', 'raw_flutter_test1', 'test', 'project');
  await Shell().cd(dir).run('flutter run');
}
