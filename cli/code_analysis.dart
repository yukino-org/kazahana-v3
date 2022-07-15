import 'dart:io';
import 'utils/exports.dart';

const Logger _logger = Logger('code-analysis');

Future<void> main() async {
  final Stopwatch watch = Stopwatch()..start();
  _logger.info('Checking code format...');
  await checkCodeFormat();
  watch.stop();
  _logger.info('Validated code format in ${watch.elapsedMilliseconds}ms');

  watch.reset();
  _logger.info('Analyzing code...');
  await analyzeCode();
  watch.stop();
  _logger.info('Analyzed code in ${watch.elapsedMilliseconds}ms');
}

Future<void> analyzeCode() async {
  final ProcessResult result =
      await Process.run('flutter', <String>['analyze']);
  if (result.exitCode == 0) return;

  throw Exception(
    'Code analyse failed with exit code ${result.exitCode}\nstdout: ${result.stdout}\nstdout: ${result.stderr}',
  );
}

Future<void> checkCodeFormat() async {
  final ProcessResult result = await Process.run(
    'flutter',
    <String>[
      'format',
      '--output=none',
      '--set-exit-if-changed',
      '.',
    ],
  );
  if (result.exitCode == 0) return;

  final List<String> files = RegExp('Changed (.*)')
      .allMatches(result.stdout.toString())
      .map((final RegExpMatch x) => x.group(1)!)
      .toList();

  final RegExp ignoredFilesRegex = RegExp(r'\.g\.dart$');
  final List<String> filtered =
      files.where(ignoredFilesRegex.hasMatch).toList();

  if (filtered.isNotEmpty) {
    throw Exception('Invalid files: ${filtered.join(' ')}');
  }
}
