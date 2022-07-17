import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:perks/perks.dart';
import '../../paths.dart';
import '../../utils/exports.dart';

abstract class CacheDatabase {
  static const String kDataKey = 'data';
  static const String kExpiresAtKey = 'expires_at';
  static const int recommendedTtlMs = 21600000;

  static final String cacheFilePath = path.join(Paths.docsDir.path, 'cache.db');

  static final PerksNameValueBox<JsonMap> box = PerksNameValueBox<JsonMap>(
    adapter: PerksFileAdapter(cacheFilePath),
  );

  static Future<void> initialize() async {
    _removeExpiredData();
  }

  static Future<T?> get<T>(final String key) async {
    final JsonMap? data = await box.get(key);
    if (data == null) return null;

    final T? value = data[kDataKey] as T?;
    final int? expiresAtMs = data[kExpiresAtKey] as int?;

    if (expiresAtMs != null &&
        expiresAtMs < DateTime.now().millisecondsSinceEpoch) {
      await box.delete(key);
      return null;
    }

    return value;
  }

  static Future<void> set<T>(
    final String key,
    final T? data, {
    final int? ttlMs,
  }) async {
    if (data == null) return delete(key);

    await box.set(key, <dynamic, dynamic>{
      kDataKey: data,
      if (ttlMs != null)
        kExpiresAtKey: DateTime.now().millisecondsSinceEpoch + ttlMs,
    });
  }

  static Future<void> delete(final String key) async => box.delete(key);

  static Future<void> _removeExpiredData() async {
    await box.transaction((final PerksNameValueMap<JsonMap> data) async {
      await compute(_filterExpiredData, data);
      return data;
    });
  }

  static void _filterExpiredData(
    final Map<String, JsonMap> data,
  ) {
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    for (final MapEntry<String, JsonMap> x in data.entries) {
      final int? expiresAtMs = x.value[kExpiresAtKey] as int?;
      if (expiresAtMs != null && expiresAtMs < nowMs) {
        data.remove(x.key);
      }
    }
  }
}
