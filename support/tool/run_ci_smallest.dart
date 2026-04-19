import 'package:dev_build/package.dart';

Future<void> main() async {
  // Ci on this package only
  await packageRunCi('.');
}
