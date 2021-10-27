abstract class AniListFuzzyDate {
  static const String query = '''
{
  year
  month
  day
}
''';

  static DateTime? toDateTime(final Map<dynamic, dynamic> json) =>
      <String>['year', 'month', 'day'].every((final String x) => json[x] is int)
          ? DateTime(
              json['year'] as int,
              json['month'] as int,
              json['day'] as int,
            )
          : null;
}
