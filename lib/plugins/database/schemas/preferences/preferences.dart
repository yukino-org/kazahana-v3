import 'package:extensions/extensions.dart' as extensions;
import 'package:hive/hive.dart';
import '../../database.dart';

part 'preferences.g.dart';

@HiveType(typeId: TypeIds.preferences)
class PreferencesSchema extends HiveObject {
  PreferencesSchema({
    final this.lastSelectedSearchType,
    final this.lastSelectedSearchPlugins,
  });

  @HiveField(1)
  String? lastSelectedSearchType;

  @HiveField(2)
  Map<String, String>? lastSelectedSearchPlugins;

  void setLastSelectedSearchPlugin(
    final extensions.ExtensionType type,
    final extensions.BaseExtractor ext,
  ) {
    lastSelectedSearchPlugins = <String, String>{
      type.type: ext.id,
      if (lastSelectedSearchPlugins != null) ...lastSelectedSearchPlugins!
    };
  }
}
