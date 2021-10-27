import '../../provider.dart';

enum AniListCharacterRole {
  main,
  supporting,
  background,
}

extension AniListCharacterRoleUtils on AniListCharacterRole {
  String get role => toString().split('.').last.toUpperCase();
}

class AniListCharacter {
  AniListCharacter({
    required final this.id,
    required final this.nameUserPreferred,
    required final this.imageMedium,
    required final this.role,
  });

  factory AniListCharacter.fromJson(
    final Map<dynamic, dynamic> edge,
    final Map<dynamic, dynamic> json,
  ) =>
      AniListCharacter(
        id: json['id'] as int,
        nameUserPreferred: json['name']['userPreferred'] as String,
        imageMedium: json['image']['medium'] as String,
        role: AniListCharacterRole.values.firstWhere(
          (final AniListCharacterRole role) =>
              role.role == (edge['role'] as String),
        ),
      );

  static const String query = '''
{
  edges {
    role
  }
  nodes {
    id
    name {
      userPreferred
    }
    image {
      medium
    }
  }
}
  ''';

  final int id;
  final String nameUserPreferred;
  final String imageMedium;
  final AniListCharacterRole role;

  Character toCharacter() => Character(
        name: nameUserPreferred,
        image: imageMedium,
        role: role.role,
      );
}
