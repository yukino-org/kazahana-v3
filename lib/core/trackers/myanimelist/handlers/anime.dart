import 'dart:convert';
import '../myanimelist.dart';

class SearchAnimeEntity {
  SearchAnimeEntity({
    required final this.nodeId,
    required final this.title,
    required final this.mainPictureMedium,
    required final this.mainPictureLarge,
  });

  factory SearchAnimeEntity.fromJson(final Map<dynamic, dynamic> json) =>
      SearchAnimeEntity(
        nodeId: json['node']['id'] as int,
        title: json['node']['title'] as String,
        mainPictureMedium: json['node']['main_picture']['medium'] as String,
        mainPictureLarge: json['node']['main_picture']['large'] as String,
      );

  final int nodeId;
  final String title;
  final String mainPictureMedium;
  final String mainPictureLarge;
}

Future<List<SearchAnimeEntity>> searchAnime(final String terms) async {
  final String res = await MyAnimeListManager.request(
    MyAnimeListRequestMethods.get,
    '/anime?q=$terms&limit=10',
  );

  return (json.decode(res)['data'] as List<dynamic>)
      .cast<Map<dynamic, dynamic>>()
      .map((final Map<dynamic, dynamic> x) => SearchAnimeEntity.fromJson(x))
      .toList();
}
