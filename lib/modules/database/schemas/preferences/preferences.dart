import 'package:extensions/extensions.dart';
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
    final ExtensionType type,
    final BaseExtractor ext,
  ) {
    lastSelectedSearchPlugins = <String, String>{
      if (lastSelectedSearchPlugins != null) ...lastSelectedSearchPlugins!,
      type.type: ext.id,
    };
  }
}
