import 'tasks/build_runner.dart' as build_runner;
import 'tasks/i18n.dart' as i18n;
import 'tasks/icon.dart' as icon;
import 'tasks/meta.dart' as meta;

Future<void> main(final List<String> args) async {
  await i18n.main(args);
  await build_runner.main(args);
  await meta.main();
  await icon.main();
}
