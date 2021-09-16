import '../anilist.dart';

class UserInfo {
  UserInfo({
    required final this.id,
    required final this.name,
    required final this.avatarMedium,
  });

  factory UserInfo.fromJson(final Map<dynamic, dynamic> json) => UserInfo(
        id: json['id'] as int,
        name: json['name'] as String,
        avatarMedium: json['avatar']['medium'] as String,
      );

  int id;
  String name;
  String avatarMedium;
}

UserInfo? _cachedUser;

Future<UserInfo> getUserInfo({
  final bool force = false,
}) async {
  if (!force && _cachedUser != null) {
    return _cachedUser!;
  }

  const String query = '''
query {
  Viewer {
    id
    name
    avatar {
      medium
    }
  }
}
  ''';

  final dynamic res = await AnilistManager.request(
    RequestBody(
      query: query,
    ),
  );

  final UserInfo info =
      UserInfo.fromJson(res['data']['Viewer'] as Map<dynamic, dynamic>);

  _cachedUser = info;
  return info;
}
