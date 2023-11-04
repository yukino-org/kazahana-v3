import 'package:utilx/utilx.dart';
import '../models/exports.dart';
import 'graphql.dart';

abstract class AnilistMediaListEndpoints {
  static Future<List<AnilistMedia>> fetch({
    required final int userId,
    required final AnilistMediaType type,
    required final AnilistMediaListStatus status,
    required final AnilistMediaListSort sort,
    final int page = 1,
    final int perPage = 20,
  }) async {
    final AnilistGraphQLResponse resp = await AnilistGraphQL.request(
      AnilistGraphQLRequest(
        query: '''
query (
  \$page: Int
  \$perPage: Int
  \$userId: Int
  \$type: MediaType
  \$status: MediaListStatus
  \$sort: [MediaListSort]
) {
  Page (page: \$page, perPage: \$perPage) {
    mediaList (
      userId: \$userId
      type: \$type
      status: \$status
      sort: \$sort
    ) {
      media ${AnilistMedia.query}
    }
  }
}
''',
        variables: <String, dynamic>{
          'page': page,
          'perPage': perPage,
          'userId': userId,
          'type': type.stringify,
          'status': status.stringify,
          'sort': sort.stringify,
        },
      ),
    );

    final JsonMap? data = resp.data;
    if (data == null) throw resp.asException;

    return MapUtils.get<List<dynamic>>(data, <String>['Page', 'mediaList'])
        .cast<JsonMap>()
        .map((final JsonMap x) => AnilistMedia(x['media'] as JsonMap))
        .toList();
  }
}
