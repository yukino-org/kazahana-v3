import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:perks/perks.dart';
import '../../paths.dart';
import '../../utils/exports.dart';
import 'schema.dart';

abstract class SettingsDatabase {
  static final PerksFileAdapter adapter =
      PerksFileAdapter(path.join(Paths.docsDir.path, 'settings.json'));

  static late SettingsSchema settings;

  static Future<void> initialize() async {
    final String content = await adapter.read();
    settings = content.isNotEmpty
        ? SettingsSchema.fromJson(json.decode(content) as JsonMap)
        : SettingsSchema();
  }

  static Future<void> save() async {
    await adapter.write(json.encode(settings.toJson()));
  }
}
