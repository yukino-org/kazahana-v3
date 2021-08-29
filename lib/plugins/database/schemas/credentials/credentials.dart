import 'package:hive/hive.dart';
import '../../database.dart';

part 'credentials.g.dart';

@HiveType(typeId: TypeIds.credentials)
class CredentialsSchema extends HiveObject {
  CredentialsSchema({
    final this.anilist,
  });

  @HiveField(1)
  final Map<dynamic, dynamic>? anilist;
}
