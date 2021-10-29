import '../../database.dart';
import '../../objectbox/objectbox.g.dart';

export './schema.dart';

abstract class SettingsBox {
  static Box<SettingsSchema> get box =>
      Box<SettingsSchema>(DatabaseManager.store);

  static SettingsSchema get() =>
      box.query().build().findUnique() ?? SettingsSchema();

  static Future<void> save(final SettingsSchema value) async {
    await box.putAsync(value);
  }
}
