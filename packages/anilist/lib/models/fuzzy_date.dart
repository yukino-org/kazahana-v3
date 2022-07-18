import 'package:utilx/utils.dart';

class AnilistFuzzyDate {
  const AnilistFuzzyDate(this.json);

  final JsonMap json;

  int? get year => json['year'] as int?;
  int? get month => json['month'] as int?;
  int? get day => json['day'] as int?;

  bool get isValidDateTime => year != null && month != null && day != null;
  DateTime? get asDateTime =>
      isValidDateTime ? DateTime(year!, month!, day!) : null;

  static const String query = '''
{
  year
  month
  day
}
''';
}
