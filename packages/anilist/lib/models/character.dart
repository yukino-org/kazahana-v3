import 'package:utilx/utils.dart';
import '../utils.dart';
import 'fuzzy_date.dart';

class AnilistCharacter {
  const AnilistCharacter(this.json);

  final JsonMap json;

  int get id => json['id'] as int;
  JsonMap get name => json['name'] as JsonMap;
  String? get nameFirst => name['first'] as String?;
  String? get nameMiddle => name['middle'] as String?;
  String? get nameLast => name['last'] as String?;
  String get nameFull => name['full'] as String;
  String? get nameNative => name['native'] as String?;
  String get nameUserPreferred => name['userPreferred'] as String;
  JsonMap get image => json['image'] as JsonMap;
  String get imageLarge => image['large'] as String;
  String get imageMedium => image['medium'] as String;
  String? get descriptionRaw => json['description'] as String?;
  String? get description =>
      descriptionRaw != null ? stripHtmlTags(descriptionRaw!) : null;
  String? get gender => json['gender'] as String?;
  JsonMap get dateOfBirthRaw => json['dateOfBirth'] as JsonMap;
  AnilistFuzzyDate get dateOfBirth => AnilistFuzzyDate(dateOfBirthRaw);
  String? get age => json['age'] as String?;
  String? get bloodType => json['bloodType'] as String?;

  static const String query = '''
{
  id
  name {
    first
    middle
    last
    full
    native
    userPreferred
  }
  image {
    large
    medium
  }
  description
  gender
  dateOfBirth ${AnilistFuzzyDate.query}
  age
  bloodType
}
''';
}
