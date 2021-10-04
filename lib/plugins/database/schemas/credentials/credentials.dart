import 'package:hive/hive.dart';
import '../../database.dart';

part 'credentials.g.dart';

@HiveType(typeId: TypeIds.credentials)
class CredentialsSchema extends HiveObject {
  CredentialsSchema({
    final this.anilist,
    final this.myanimelist,
  });

  @HiveField(1)
  Map<dynamic, dynamic>? anilist;

  @HiveField(2)
  Map<dynamic, dynamic>? myanimelist;
}
