import 'dart:convert';
import '../myanimelist.dart';

class UserInfo {
  UserInfo({
    required final this.id,
    required final this.name,
  });

  factory UserInfo.fromJson(final Map<dynamic, dynamic> json) => UserInfo(
        id: json['id'] as int,
        name: json['name'] as String,
      );

  int id;
  String name;
}

UserInfo? _cachedUser;

Future<UserInfo> getUserInfo({
  final bool force = false,
}) async {
  if (!force && _cachedUser != null) {
    return _cachedUser!;
  }

  final String res = await MyAnimeListManager.request(
    MyAnimeListRequestMethods.get,
    '/users/@me',
  );

  final UserInfo info =
      UserInfo.fromJson(json.decode(res) as Map<dynamic, dynamic>);

  _cachedUser = info;
  return info;
}
