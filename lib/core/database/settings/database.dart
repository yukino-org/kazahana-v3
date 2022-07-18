import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../../paths.dart';
import '../../utils/exports.dart';
import 'schema.dart';

abstract class SettingsDatabase {
  static late SettingsSchema settings;

  static Future<void> initialize() async {
    final File file = getSettingsFile();
    if (await file.exists()) {
      final String contents = await file.readAsString();
      settings = SettingsSchema.fromJson(json.decode(contents) as JsonMap);
      return;
    }
    settings = SettingsSchema();
  }

  static Future<void> save() async {
    final File file = getSettingsFile();
    await FSUtils.ensureFile(file);
    await file.writeAsString(json.encode(settings.toJson()));
  }

  static File getSettingsFile() =>
      File(path.join(Paths.docsDir.path, 'settings.json'));
}
