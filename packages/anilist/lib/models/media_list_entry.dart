import 'package:utilx/utils.dart';
import 'fuzzy_date.dart';
import 'media_list_status.dart';

class AnilistMediaListEntry {
  const AnilistMediaListEntry(this.json);

  final JsonMap json;

  int get id => json['id'] as int;
  int get userId => json['userId'] as int;
  int get mediaId => json['mediaId'] as int;
  AnilistMediaListStatus get status =>
      parseAnilistMediaListStatus(json['status'] as String);
  int get progress => json['progress'] as int;
  int? get progressVolumes => json['progressVolumes'] as int?;
  int get repeat => json['repeat'] as int;
  int get score => json['score'] as int;
  JsonMap? get startedAtRaw => json['startedAt'] as JsonMap?;
  AnilistFuzzyDate? get startedAt =>
      startedAtRaw != null ? AnilistFuzzyDate(startedAtRaw!) : null;
  JsonMap? get completedAtRaw => json['completedAt'] as JsonMap?;
  AnilistFuzzyDate? get completedAt =>
      completedAtRaw != null ? AnilistFuzzyDate(completedAtRaw!) : null;

  static const String query = '''
{
  id
  userId
  mediaId
  status
  progress
  progressVolumes
  repeat
  score (format: POINT_100)
  startedAt ${AnilistFuzzyDate.query}
  completedAt ${AnilistFuzzyDate.query}
}
''';
}
