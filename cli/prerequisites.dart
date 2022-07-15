import 'tasks/build_runner.dart' as build_runner;
import 'tasks/icon.dart' as icon;
import 'tasks/meta.dart' as meta;

Future<void> main(final List<String> args) async {
  await meta.main();
  await build_runner.main(args);
  await icon.main();
}
