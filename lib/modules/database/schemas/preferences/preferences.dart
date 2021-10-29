import '../../database.dart';
import '../../objectbox/objectbox.g.dart';

export './schema.dart';

abstract class PreferencesBox {
  static Box<PreferencesSchema> get box =>
      Box<PreferencesSchema>(DatabaseManager.store);

  static PreferencesSchema get() =>
      box.query().build().findUnique() ?? PreferencesSchema();

  static Future<void> save(final PreferencesSchema value) async {
    await box.putAsync(value);
  }
}
