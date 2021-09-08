import 'package:hive/hive.dart';
import '../../database.dart';

part 'preferences.g.dart';

@HiveType(typeId: TypeIds.preferences)
class PreferencesSchema extends HiveObject {
  PreferencesSchema({
    final this.lastSelectedSearchPlugin,
  });

  @HiveField(1)
  String? lastSelectedSearchPlugin;

  @HiveField(2)
  String? lastSelectedSearchType;
}
