import 'dart:convert';
import '../myanimelist.dart';

class MyAnimeListSearchManga {
  MyAnimeListSearchManga({
    required final this.nodeId,
    required final this.title,
    required final this.mainPictureMedium,
    required final this.mainPictureLarge,
  });

  factory MyAnimeListSearchManga.fromJson(final Map<dynamic, dynamic> json) =>
      MyAnimeListSearchManga(
        nodeId: json['node']['id'] as int,
        title: json['node']['title'] as String,
        mainPictureMedium: json['node']['main_picture']['medium'] as String,
        mainPictureLarge: json['node']['main_picture']['large'] as String,
      );

  final int nodeId;
  final String title;
  final String mainPictureMedium;
  final String mainPictureLarge;

  static Future<List<MyAnimeListSearchManga>> searchManga(
    final String terms,
  ) async {
    final String res = await MyAnimeListManager.request(
      MyAnimeListRequestMethods.get,
      '/manga?q=$terms&limit=10',
    );

    return (json.decode(res)['data'] as List<dynamic>)
        .cast<Map<dynamic, dynamic>>()
        .map(
          (final Map<dynamic, dynamic> x) => MyAnimeListSearchManga.fromJson(x),
        )
        .toList();
  }
}
