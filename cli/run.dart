import 'dart:io';
import 'prerequisites.dart' as prerequisites;
import 'utils/exports.dart';

const Logger _logger = Logger('run');

Future<void> main(final List<String> args) async {
  await prerequisites.main(args);
  _logger.info('Starting...');

  final Process process = await Process.start(
    'flutter',
    <String>['run'],
    mode: ProcessStartMode.inheritStdio,
    runInShell: true,
  );

  final int exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw Exception('Debug run failed with error code $exitCode');
  }
}
