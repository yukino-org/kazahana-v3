import 'package:hive/hive.dart';
import '../../database.dart';

part 'preferences.g.dart';

@HiveType(typeId: TypeIds.preferences)
class PreferencesSchema extends HiveObject {
  PreferencesSchema({
    final this.lastSelectedSearchType,
    final this.lastSelectedSearchPlugins,
  });

  @HiveField(2)
  String? lastSelectedSearchType;

  @HiveField(3)
  Map<String, String>? lastSelectedSearchPlugins;
}
