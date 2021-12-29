import '../../database.dart';
import '../../objectbox/objectbox.g.dart';

export './schema.dart';

abstract class CachedPreferencesBox {
  static Box<CachedPreferencesSchema> get box =>
      Box<CachedPreferencesSchema>(DatabaseManager.store);

  static CachedPreferencesSchema get() =>
      box.query().build().findUnique() ?? CachedPreferencesSchema();

  static Future<void> save(final CachedPreferencesSchema value) async {
    await box.putAsync(value);
  }
}
