import '../anilist.dart';

Future<List<Media>> getRecommended(
  final int page, {
  final int perPage = 50,
  final bool onList = true,
}) async {
  const String query = '''
query (
  \$page: Int,
  \$perpage: Int,
  \$onlist: Boolean
) {
  Page (
    page: \$page,
    perPage: \$perpage
  ) {
    recommendations (
      sort: RATING,
      onList: \$onlist
    ) {
      media ${Media.query}
    }
  }
}
  ''';

  final dynamic res = await AnilistManager.request(
    RequestBody(
      query: query,
      variables: <dynamic, dynamic>{
        'page': page,
        'perpage': perPage,
        'onlist': onList,
      },
    ),
  );

  return (res['data']['Page']['recommendations'] as List<dynamic>)
      .map(
        (final dynamic x) =>
            Media.fromJson(x['media'] as Map<dynamic, dynamic>),
      )
      .toList();
}
