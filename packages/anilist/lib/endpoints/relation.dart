import 'package:utilx/utils.dart';
import '../models/exports.dart';
import 'graphql.dart';

abstract class AnilistMediaRelationEndpoints {
  static Future<List<AnilistRelationEdge>> fetchRelations(
    final int mediaId,
  ) async {
    final AnilistGraphQLResponse resp = await AnilistGraphQL.request(
      AnilistGraphQLRequest(
        query: '''
query (\$id: Int) {
  Media (id: \$id) {
    relations {
      edges {
        id
        relationType
        node ${AnilistMedia.query}
      }
    }
  }
}
''',
        variables: <String, dynamic>{
          'id': mediaId,
        },
      ),
    );

    final JsonMap? data = resp.data;
    if (data == null) throw resp.asException;

    return MapUtils.get<List<dynamic>>(
      data,
      <String>['Media', 'relations', 'edges'],
    ).map((final dynamic x) => AnilistRelationEdge(x as JsonMap)).toList();
  }
}
