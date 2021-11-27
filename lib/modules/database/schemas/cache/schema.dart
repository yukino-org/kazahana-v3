import 'dart:convert';
import 'package:objectbox/objectbox.dart';

const int _cachedTime = 0;

@Entity()
class CacheSchema {
  CacheSchema({
    final this.key = '__unassigned__',
    final this.value_,
    final this.cachedTime = _cachedTime,
  });

  int id = 0;
  String key;
  int cachedTime;

  String? value_;
  dynamic get value => value_ != null ? json.decode(value_!) : null;
  set value(final dynamic val) {
    value_ = json.encode(val);
  }
}
