import 'package:hive/hive.dart';
import '../../database.dart';

part 'preferences.g.dart';

const Map<String, String> _lastSelectedSearchPlugins = <String, String>{};

@HiveType(typeId: TypeIds.preferences)
class PreferencesSchema extends HiveObject {
  PreferencesSchema({
    final this.lastSelectedSearchType,
    final this.lastSelectedSearchPlugins = _lastSelectedSearchPlugins,
  });

  @HiveField(2)
  String? lastSelectedSearchType;

  @HiveField(3, defaultValue: _lastSelectedSearchPlugins)
  Map<String, String> lastSelectedSearchPlugins;
}
