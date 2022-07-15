import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/exports.dart';

final String pubspecYamlPath = path.join(Paths.rootDir, 'pubspec.yaml');

Future<String> getVersion() async {
  final String content = await File(pubspecYamlPath).readAsString();
  return RegExp(r'version: ([\w+\.-]+)').firstMatch(content)!.group(1)!;
}
