import 'dart:convert';
import 'package:objectbox/objectbox.dart';

const int _cachedTime = 0;

@Entity()
class CacheSchema {
  CacheSchema({
    this.key = '__unassigned__',
    this.value_,
    this.cachedTime = _cachedTime,
  });

  int id = 0;
  String key;
  int cachedTime;

  String? value_;
  dynamic get value => value_ != null ? json.decode(value_!) : null;
  set value(final dynamic val) => json.encode(value_);
}
