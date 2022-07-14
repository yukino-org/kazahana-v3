import 'dart:io';
import '../utils/exports.dart';

const Logger _logger = Logger('build_runner');

Future<void> main() async {
  final Stopwatch watch = Stopwatch()..start();
  _logger.info('Running...');
  final Process process = await Process.start(
    'dart',
    <String>['run', 'build_runner', 'build'],
    mode: ProcessStartMode.inheritStdio,
  );
  watch.stop();
  final int exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw Exception('Build runner failed with error code $exitCode');
  }
  _logger.info('Finished in ${watch.elapsedMilliseconds}ms');
}
