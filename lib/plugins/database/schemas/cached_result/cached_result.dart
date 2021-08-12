import 'package:hive/hive.dart';
import '../../database.dart';

part 'cached_result.g.dart';

@HiveType(typeId: TypeIds.cachedResult)
class CachedResultSchema extends HiveObject {
  CachedResultSchema({
    required final this.info,
    required final this.cachedTime,
  });

  @HiveField(1)
  final Map<dynamic, dynamic> info;

  @HiveField(2)
  final int cachedTime;
}
