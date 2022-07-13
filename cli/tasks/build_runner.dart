import 'dart:io';
import '../utils/exports.dart';

const Logger _logger = Logger('build_runner');

Future<void> main() async {
  final StopWatch watch = StopWatch.createAndStart();
  _logger.info('Running...');
  final Process process = await Process.start(
    'dart',
    <String>['run', 'build_runner', 'build'],
    mode: ProcessStartMode.inheritStdio,
  );
  final int exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw Exception('Build runner failed with error code $exitCode');
  }
  _logger.info('Finished in ${watch.stop()}ms');
}
