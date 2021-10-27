import 'dart:convert';
import '../myanimelist.dart';

class MyAnimeListUserInfo {
  MyAnimeListUserInfo({
    required final this.id,
    required final this.name,
  });

  factory MyAnimeListUserInfo.fromJson(final Map<dynamic, dynamic> json) =>
      MyAnimeListUserInfo(
        id: json['id'] as int,
        name: json['name'] as String,
      );

  int id;
  String name;

  static MyAnimeListUserInfo? _cachedUser;

  static Future<MyAnimeListUserInfo> getUserInfo({
    final bool force = false,
  }) async {
    if (!force && _cachedUser != null) {
      return _cachedUser!;
    }

    final String res = await MyAnimeListManager.request(
      MyAnimeListRequestMethods.get,
      '/users/@me',
    );

    final MyAnimeListUserInfo info =
        MyAnimeListUserInfo.fromJson(json.decode(res) as Map<dynamic, dynamic>);

    _cachedUser = info;
    return info;
  }
}
