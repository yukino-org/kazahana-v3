import 'tasks/build_runner.dart' as build_runner;
import 'tasks/icon.dart' as icon;
import 'tasks/meta.dart' as meta;

Future<void> main() async {
  await meta.main();
  await build_runner.main();
  await icon.main();
}
