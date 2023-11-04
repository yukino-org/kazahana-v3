import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/exports.dart';
import 'version.dart';

const Logger _logger = Logger('meta');
final String generatedAppMetaPath =
    path.join(Paths.libDir, 'core/app/meta.g.dart');

Future<void> main() async {
  await File(generatedAppMetaPath)
      .writeAsString(await getGeneratedAppMetaContent());
  _logger.info('Generated $generatedAppMetaPath');
}

Future<String> getGeneratedAppMetaContent() async => '''
part of 'meta.dart';

abstract class _GeneratedAppMeta {
  static const String version = '${await getVersion()}';
  static const int builtAtMs = ${DateTime.now().millisecondsSinceEpoch};
}
''';
