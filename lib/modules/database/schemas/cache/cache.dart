import '../../database.dart';
import '../../objectbox/objectbox.g.dart';

export './schema.dart';

abstract class CacheBox {
  static Box<CacheSchema> get box => Box<CacheSchema>(DatabaseManager.store);

  static CacheSchema? get(final String key) =>
      box.query(CacheSchema_.key.equals(key)).build().findUnique();

  static Future<void> save(final CacheSchema value) async {
    await box.putAsync(value);
  }

  static Future<void> saveKV(
    final String key,
    final dynamic value,
    final int cachedTime,
  ) async {
    await save(
      (get(key) ?? CacheSchema())
        ..key = key
        ..value = value
        ..cachedTime = cachedTime,
    );
  }

  static bool delete(final String key) {
    final CacheSchema? cache = CacheBox.get(key);

    if (cache != null) {
      return CacheBox.box.remove(cache.id);
    }

    return false;
  }
}
