import 'package:hive/hive.dart';
import '../../database.dart';

part 'cache.g.dart';

@HiveType(typeId: TypeIds.cache)
class CacheSchema extends HiveObject {
  CacheSchema(this.value, this.cachedTime);

  @HiveField(1)
  dynamic value;

  @HiveField(2)
  final int cachedTime;
}
