enum CharacterRole {
  main,
  supporting,
  background,
}

extension CharacterRoleUtils on CharacterRole {
  String get role => toString().split('.').last.toUpperCase();
}

class Character {
  Character({
    required final this.id,
    required final this.nameUserPreferred,
    required final this.imageMedium,
    required final this.role,
  });

  factory Character.fromJson(
    final Map<dynamic, dynamic> edge,
    final Map<dynamic, dynamic> json,
  ) =>
      Character(
        id: json['id'] as int,
        nameUserPreferred: json['name']['userPreferred'] as String,
        imageMedium: json['image']['medium'] as String,
        role: CharacterRole.values.firstWhere(
          (final CharacterRole role) => role.role == (edge['role'] as String),
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
  final CharacterRole role;
}
