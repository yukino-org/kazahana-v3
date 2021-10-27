import 'package:collection/collection.dart';
import 'package:extensions/extensions.dart';
import './fuzzy_date.dart';
import '../../../utils/utils.dart';
import '../anilist.dart';

enum AniListMediaFormat {
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

extension AniListMediaFormatUtils on AniListMediaFormat {
  String get format =>
      StringUtils.pascalToSnakeCase(toString().split('.').last).toUpperCase();
}

enum AniListMediaSeason {
  winter,
  spring,
  summer,
  fall,
}

extension AniListMediaSeasonUtils on AniListMediaSeason {
  String get season => toString().split('.').last.toUpperCase();
}

class AniListMedia {
  AniListMedia({
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

  factory AniListMedia.fromJson(final Map<dynamic, dynamic> json) =>
      AniListMedia(
        id: json['id'] as int,
        idMal: json['idMal'] as int?,
        titleUserPreferred: json['title']['userPreferred'] as String,
        type: ExtensionType.values.firstWhere(
          (final ExtensionType type) =>
              type.type.toUpperCase() == (json['type'] as String),
        ),
        format: AniListMediaFormat.values.firstWhere(
          (final AniListMediaFormat type) =>
              type.format == (json['format'] as String),
        ),
        description: json['description'] as String?,
        startDate: AniListFuzzyDate.toDateTime(
          json['startDate'] as Map<dynamic, dynamic>,
        ),
        endDate: AniListFuzzyDate.toDateTime(
          json['endDate'] as Map<dynamic, dynamic>,
        ),
        season: AniListMediaSeason.values.firstWhereOrNull(
          (final AniListMediaSeason type) =>
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
              (final int k, final dynamic x) => MapEntry<int, AniListCharacter>(
                k,
                AniListCharacter.fromJson(
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
  startDate ${AniListFuzzyDate.query}
  endDate ${AniListFuzzyDate.query}
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
  characters(sort: ROLE, page: 0, perPage: 25) ${AniListCharacter.query}
  meanScore
  isAdult
  siteUrl
}
  ''';

  final int id;
  final int? idMal;
  final String titleUserPreferred;
  final ExtensionType type;
  final AniListMediaFormat format;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final AniListMediaSeason? season;
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
  final List<AniListCharacter> characters;
  final int? meanScore;
  final bool isAdult;
  final String siteUrl;

  static Future<List<AniListMedia>> search(
    final String title,
    final ExtensionType type, [
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
    media (search: \$search, type: \$type) ${AniListMedia.query}
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
          'type': type.type.toUpperCase(),
        },
      ),
    );

    return (res['data']['Page']['media'] as List<dynamic>)
        .cast<Map<dynamic, dynamic>>()
        .map((final Map<dynamic, dynamic> x) => AniListMedia.fromJson(x))
        .toList();
  }

  static Future<AniListMedia> getMediaFromId(
    final int mediaId,
  ) async {
    const String query = '''
query (
  \$mediaId: Int
) {
  Media (id: \$mediaId) ${AniListMedia.query}
}
    ''';

    final dynamic res = await AnilistManager.request(
      RequestBody(
        query: query,
        variables: <dynamic, dynamic>{
          'mediaId': mediaId,
        },
      ),
    );

    return AniListMedia.fromJson(res['data']['Media'] as Map<dynamic, dynamic>);
  }
}
