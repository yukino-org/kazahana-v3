import 'package:collection/collection.dart';
import './_fuzzy_date.dart';
import '../../../../plugins/helpers/utils/string.dart';
import '../anilist.dart';

enum MediaType {
  anime,
  manga,
}

extension MediaTypeUtils on MediaType {
  String get type => toString().split('.').last.toUpperCase();
}

enum MediaFormat {
  tv,
  tvShort,
  movie,
  special,
  ova,
  ona,
  music,
  manga,
  novel,
  oneShot,
}

extension MediaFormatUtils on MediaFormat {
  String get format =>
      StringUtils.pascalToSnakeCase(toString().split('.').last).toUpperCase();
}

enum MediaSeason {
  winter,
  spring,
  summer,
  fall,
}

extension MediaSeasonUtils on MediaSeason {
  String get season => toString().split('.').last.toUpperCase();
}

class Media {
  Media({
    required final this.id,
    required final this.idMal,
    required final this.titleUserPreferred,
    required final this.type,
    required final this.format,
    required final this.description,
    required final this.startDate,
    required final this.endDate,
    required final this.season,
    required final this.duration,
    required final this.chapters,
    required final this.volumes,
    required final this.episodes,
    required final this.coverImageMedium,
    required final this.coverImageExtraLarge,
    required final this.bannerImage,
    required final this.genres,
    required final this.synonyms,
    required final this.tags,
    required final this.characters,
    required final this.meanScore,
    required final this.isAdult,
    required final this.siteUrl,
  });

  factory Media.fromJson(final Map<dynamic, dynamic> json) => Media(
        id: json['id'] as int,
        idMal: json['idMal'] as int?,
        titleUserPreferred: json['title']['userPreferred'] as String,
        type: MediaType.values.firstWhere(
          (final MediaType type) => type.type == (json['type'] as String),
        ),
        format: MediaFormat.values.firstWhere(
          (final MediaFormat type) => type.format == (json['format'] as String),
        ),
        description: json['description'] as String?,
        startDate:
            FuzzyDate.toDateTime(json['startDate'] as Map<dynamic, dynamic>),
        endDate: FuzzyDate.toDateTime(json['endDate'] as Map<dynamic, dynamic>),
        season: MediaSeason.values.firstWhereOrNull(
          (final MediaSeason type) =>
              type.season == (json['season'] as String?),
        ),
        duration: json['duration'] as int?,
        chapters: json['chapters'] as int?,
        volumes: json['volumes'] as int?,
        episodes: json['episodes'] as int?,
        coverImageMedium: json['coverImage']['medium'] as String,
        coverImageExtraLarge: json['coverImage']['extraLarge'] as String,
        bannerImage: json['bannerImage'] as String?,
        genres: (json['genres'] as List<dynamic>).cast<String>(),
        synonyms: (json['synonyms'] as List<dynamic>).cast<String>(),
        tags: (json['tags'] as List<dynamic>)
            .map((final dynamic x) => x['name'] as String)
            .toList(),
        characters: (json['characters']['edges'] as List<dynamic>)
            .asMap()
            .map(
              (final int k, final dynamic x) => MapEntry<int, Character>(
                k,
                Character.fromJson(
                  x as Map<dynamic, dynamic>,
                  json['characters']['nodes'][k] as Map<dynamic, dynamic>,
                ),
              ),
            )
            .values
            .toList(),
        meanScore: json['meanScore'] as int?,
        isAdult: json['isAdult'] as bool,
        siteUrl: json['siteUrl'] as String,
      );

  static const String query = '''
{
  id
  idMal
  title {
    userPreferred
  }
  type
  format
  description
  startDate ${FuzzyDate.query}
  endDate ${FuzzyDate.query}
  season
  episodes
  duration
  chapters
  volumes
  coverImage {
    medium
    extraLarge
  }
  bannerImage
  genres
  synonyms
  tags {
    name
  }
  characters(sort: ROLE, page: 0, perPage: 25) ${Character.query}
  meanScore
  isAdult
  siteUrl
}
  ''';

  final int id;
  final int? idMal;
  final String titleUserPreferred;
  final MediaType type;
  final MediaFormat format;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final MediaSeason? season;
  final int? duration;
  final int? chapters;
  final int? volumes;
  final int? episodes;
  final String coverImageMedium;
  final String coverImageExtraLarge;
  final String? bannerImage;
  final List<String> genres;
  final List<String> synonyms;
  final List<String> tags;
  final List<Character> characters;
  final int? meanScore;
  final bool isAdult;
  final String siteUrl;

  static Future<List<Media>> search(
    final String title,
    final MediaType type, [
    final int page = 0,
    final int perPage = 25,
  ]) async {
    const String query = '''
query (
  \$search: String,
  \$page: Int,
  \$perpage: Int,
  \$type: MediaType
) {
  Page (page: \$page, perPage: \$perpage) {
    media (search: \$search, type: \$type) ${Media.query}
  }
}
    ''';

    final dynamic res = await AnilistManager.request(
      RequestBody(
        query: query,
        variables: <dynamic, dynamic>{
          'search': title,
          'page': page,
          'perpage': perPage,
          'type': type.type,
        },
      ),
    );

    return (res['data']['Page']['media'] as List<dynamic>)
        .cast<Map<dynamic, dynamic>>()
        .map((final Map<dynamic, dynamic> x) => Media.fromJson(x))
        .toList();
  }
}
