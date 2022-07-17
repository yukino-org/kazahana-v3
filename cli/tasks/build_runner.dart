import 'dart:io';
import '../utils/exports.dart';

const Logger _logger = Logger('build_runner');

Future<void> main(final List<String> args) async {
  await runBuildRunner(
    deleteConflictingOutputs: args.contains('--force-build-runner'),
  );
}

Future<void> runBuildRunner({
  final bool deleteConflictingOutputs = false,
}) async {
  _logger.info('Running...');

  final Stopwatch watch = Stopwatch()..start();
  final Process process = await Process.start(
    'dart',
    <String>[
      'run',
      'build_runner',
      'build',
      '--fail-on-severe',
      if (deleteConflictingOutputs) '--delete-conflicting-outputs',
    ],
    mode: ProcessStartMode.inheritStdio,
  );
  watch.stop();

  final int exitCode = await process.exitCode;
  if (exitCode == 78 && !deleteConflictingOutputs) {
    _logger.info('Failed with error code $exitCode');
    _logger.info('Retrying with --delete-conflicting-outputs flag...');
    return runBuildRunner(deleteConflictingOutputs: true);
  }

  if (exitCode != 0) {
    throw Exception('Build runner failed with error code $exitCode');
  }

  _logger.info('Finished in ${watch.elapsedMilliseconds}ms');
}
