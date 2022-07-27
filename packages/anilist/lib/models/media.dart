import 'package:utilx/utils.dart';
import '../endpoints/exports.dart';
import '../utils.dart';
import 'character_edge.dart';
import 'fuzzy_date.dart';
import 'media_format.dart';
import 'media_list_entry.dart';
import 'media_status.dart';
import 'media_type.dart';
import 'relation_edge.dart';
import 'seasons.dart';

class AnilistMedia {
  AnilistMedia(this.json);

  final JsonMap json;
  List<AnilistRelationEdge>? relations;

  int get id => json['id'] as int;
  int? get idMal => json['idMal'] as int?;
  JsonMap get title => json['title'] as JsonMap;
  String get titleRomaji => title['romaji'] as String;
  String? get titleEnglish => title['english'] as String?;
  String get titleNative => title['native'] as String;
  String get titleUserPreferred => title['userPreferred'] as String;
  AnilistMediaType get type => parseAnilistMediaType(json['type'] as String);
  AnilistMediaFormat get format =>
      parseAnilistMediaFormat(json['format'] as String);
  String? get descriptionRaw => json['description'] as String?;
  String? get description =>
      descriptionRaw != null ? cleanHtml(descriptionRaw!) : null;
  JsonMap? get startDateRaw => json['startDate'] as JsonMap;
  AnilistFuzzyDate? get startDate =>
      startDateRaw != null ? AnilistFuzzyDate(startDateRaw!) : null;
  JsonMap? get endDateRaw => json['endDate'] as JsonMap;
  AnilistFuzzyDate? get endDate =>
      endDateRaw != null ? AnilistFuzzyDate(endDateRaw!) : null;
  AnimeSeasons? get season => json['season'] != null
      ? parseAnimeSeason(json['season'] as String)
      : null;
  int? get seasonYear => json['seasonYear'] as int?;
  int? get duration => json['duration'] as int?;
  int? get chapters => json['chapters'] as int?;
  int? get volumes => json['volumes'] as int?;
  int? get episodes => json['episodes'] as int?;
  JsonMap get coverImage => json['coverImage'] as JsonMap;
  String get coverImageMedium => coverImage['medium'] as String;
  String get coverImageLarge => coverImage['large'] as String;
  String get coverImageExtraLarge => coverImage['extraLarge'] as String;
  String? get coverImageColor => coverImage['color'] as String?;
  String? get bannerImage => json['bannerImage'] as String?;
  List<String> get genres => castList<String>(json['genres']);
  List<String> get synonyms => castList<String>(json['synonyms']);
  List<String> get tags => castList<JsonMap>(json['tags'])
      .map((final JsonMap x) => x['name'] as String)
      .toList();
  List<AnilistCharacterEdge> get characters =>
      castList<JsonMap>((json['characters'] as JsonMap)['edges'])
          .map((final JsonMap x) => AnilistCharacterEdge(x))
          .toList();
  int? get meanScore => json['meanScore'] as int?;
  bool get isAdult => json['isAdult'] as bool;
  String get siteUrl => json['siteUrl'] as String;
  int? get averageScore => json['averageScore'] as int?;
  int get popularity => json['popularity'] as int;
  AnilistMediaStatus get status =>
      parseAnilistMediaStatus(json['status'] as String);
  AnilistMediaListEntry? get mediaListEntry => json['mediaListEntry'] != null
      ? AnilistMediaListEntry(json['mediaListEntry'] as JsonMap)
      : null;

  Future<void> fetchAll() async {
    relations = await AnilistMediaRelationEndpoints.fetchRelations(id);
  }

  static const String query = '''
{
  id
  idMal
  title {
    romaji
    english
    native
    userPreferred
  }
  type
  format
  description
  startDate ${AnilistFuzzyDate.query}
  endDate ${AnilistFuzzyDate.query}
  season
  seasonYear
  episodes
  duration
  chapters
  volumes
  coverImage {
    medium
    large
    extraLarge
    color
  }
  bannerImage
  genres
  synonyms
  tags {
    name
  }
  characters (sort: ROLE, page: 0, perPage: 15) {
    edges ${AnilistCharacterEdge.query}
  }
  meanScore
  isAdult
  siteUrl
  averageScore
  popularity
  status
  mediaListEntry ${AnilistMediaListEntry.query}
}
''';
}
