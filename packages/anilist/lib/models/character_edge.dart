import 'package:utilx/utilx.dart';
import 'character.dart';
import 'character_role.dart';

class AnilistCharacterEdge {
  const AnilistCharacterEdge(this.json);

  final JsonMap json;

  int get id => json['id'] as int;
  AnilistCharacterRole get role =>
      parseAnilistCharacterRole(json['role'] as String);
  AnilistCharacter get node => AnilistCharacter(json['node'] as JsonMap);

  static const String query = '''
{
  node ${AnilistCharacter.query}
  id
  role
}
''';
}
