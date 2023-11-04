import 'dart:io';

Future<void> main(final List<String> args) async {
  final ProcessResult result = await Process.run(
    'npm',
    <String>['run', 'i18n:build'],
  );
  if (result.exitCode != 0) {
    throw Exception('i18n builder failed with error code $exitCode');
  }
}
