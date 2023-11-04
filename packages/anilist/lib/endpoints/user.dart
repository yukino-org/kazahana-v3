import 'package:utilx/utilx.dart';
import '../models/exports.dart';
import 'graphql.dart';

abstract class AnilistUserEndpoints {
  static Future<AnilistUser> getAuthenticatedUser() async {
    if (!AnilistGraphQL.isAuthenticated) {
      throw Exception('Authenticated required to perform this operation');
    }

    final AnilistGraphQLResponse resp = await AnilistGraphQL.request(
      const AnilistGraphQLRequest(
        query: '''
query {
  Viewer ${AnilistUser.query}
}
''',
      ),
      retryOnExpiredSession: false,
    );

    final JsonMap? data = resp.data;
    if (data == null) throw resp.asException;

    return AnilistUser(data['Viewer'] as JsonMap);
  }

  static Future<List<AnilistMedia>> search(
    final String terms, {
    final int page = 1,
    final int perPage = 20,
  }) async =>
      fetchBulk(
        <TripleTuple<String, String, dynamic>>[
          TripleTuple<String, String, dynamic>('search', 'String', terms),
        ],
        page: page,
        perPage: perPage,
      );

  static Future<List<AnilistMedia>> trendingAnimes() async {
    final DateTime now = DateTime.now();
    return fetchBulk(<TripleTuple<String, String, dynamic>>[
      TripleTuple<String, String, dynamic>(
        'type',
        'MediaType',
        AnilistMediaType.anime.stringify,
      ),
      TripleTuple<String, String, dynamic>(
        'sort',
        '[MediaSort]',
        <String>[
          AnilistMediaSort.trendingDesc.stringify,
          AnilistMediaSort.popularityDesc.stringify,
        ],
      ),
      TripleTuple<String, String, dynamic>(
        'season',
        'MediaSeason',
        getAnimeSeasonFromMonth(now.month).stringify,
      ),
      TripleTuple<String, String, dynamic>(
        'seasonYear',
        'Int',
        now.year,
      ),
    ]);
  }

  static Future<List<AnilistMedia>> topOngoingAnimes() async =>
      fetchBulk(<TripleTuple<String, String, dynamic>>[
        TripleTuple<String, String, dynamic>(
          'type',
          'MediaType',
          AnilistMediaType.anime.stringify,
        ),
        TripleTuple<String, String, dynamic>(
          'sort',
          '[MediaSort]',
          <String>[
            AnilistMediaSort.trendingDesc.stringify,
            AnilistMediaSort.popularityDesc.stringify,
          ],
        ),
        TripleTuple<String, String, dynamic>(
          'status',
          'MediaStatus',
          AnilistMediaStatus.releasing.stringify,
        ),
      ]);

  static Future<List<AnilistMedia>> mostPopularAnimes() async =>
      fetchBulk(<TripleTuple<String, String, dynamic>>[
        TripleTuple<String, String, dynamic>(
          'type',
          'MediaType',
          AnilistMediaType.anime.stringify,
        ),
        TripleTuple<String, String, dynamic>(
          'sort',
          '[MediaSort]',
          <String>[
            AnilistMediaSort.popularityDesc.stringify,
          ],
        ),
      ]);

  static Future<List<AnilistMedia>> trendingMangas() async =>
      fetchBulk(<TripleTuple<String, String, dynamic>>[
        TripleTuple<String, String, dynamic>(
          'type',
          'MediaType',
          AnilistMediaType.manga.stringify,
        ),
        TripleTuple<String, String, dynamic>(
          'sort',
          '[MediaSort]',
          <String>[
            AnilistMediaSort.trendingDesc.stringify,
            AnilistMediaSort.popularityDesc.stringify,
          ],
        ),
      ]);

  static Future<List<AnilistMedia>> topOngoingMangas() async =>
      fetchBulk(<TripleTuple<String, String, dynamic>>[
        TripleTuple<String, String, dynamic>(
          'type',
          'MediaType',
          AnilistMediaType.manga.stringify,
        ),
        TripleTuple<String, String, dynamic>(
          'sort',
          '[MediaSort]',
          <String>[
            AnilistMediaSort.trendingDesc.stringify,
            AnilistMediaSort.popularityDesc.stringify,
          ],
        ),
        TripleTuple<String, String, dynamic>(
          'status',
          'MediaStatus',
          AnilistMediaStatus.releasing.stringify,
        ),
      ]);

  static Future<List<AnilistMedia>> mostPopularMangas() async =>
      fetchBulk(<TripleTuple<String, String, dynamic>>[
        TripleTuple<String, String, dynamic>(
          'type',
          'MediaType',
          AnilistMediaType.manga.stringify,
        ),
        TripleTuple<String, String, dynamic>(
          'sort',
          '[MediaSort]',
          <String>[
            AnilistMediaSort.popularityDesc.stringify,
          ],
        ),
      ]);

  static Future<List<AnilistMedia>> fetchBulk(
    final List<TripleTuple<String, String, dynamic>> queries, {
    final int page = 1,
    final int perPage = 20,
  }) async {
    final AnilistGraphQLResponse resp = await AnilistGraphQL.request(
      AnilistGraphQLRequest(
        query: '''
query (
  \$page: Int,
  \$perPage: Int,
  ${queries.map((final TripleTuple<String, String, dynamic> x) => '\$${x.first}: ${x.middle}').join(',\n')}
) {
  Page (page: \$page, perPage: \$perPage) {
    media (
      ${queries.map((final TripleTuple<String, String, dynamic> x) => '${x.first}: \$${x.first}').join(',\n')}
    ) ${AnilistMedia.query}
  }
}
''',
        variables: <String, dynamic>{
          'page': page,
          'perPage': perPage,
          ...queries.asMap().map(
                (final _, final TripleTuple<String, String, dynamic> x) =>
                    MapEntry<String, dynamic>(x.first, x.last),
              ),
        },
      ),
    );

    final JsonMap? data = resp.data;
    if (data == null) throw resp.asException;

    return MapUtils.get<List<dynamic>>(data, <String>['Page', 'media'])
        .map((final dynamic x) => AnilistMedia(x as JsonMap))
        .toList();
  }
}
