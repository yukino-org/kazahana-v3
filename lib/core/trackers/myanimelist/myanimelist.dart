import 'package:http/http.dart' as http;
import './handlers/auth.dart';
import '../../../plugins/database/database.dart';
import '../../../plugins/helpers/querystring.dart';
import '../../secrets/myanimelist.dart';

export './handlers/anime.dart';
export './handlers/animelist.dart';
export './handlers/auth.dart';
export './handlers/manga.dart';
export './handlers/mangalist.dart';
export './handlers/user_info.dart';

enum MyAnimeListRequestMethods {
  get,
  post,
  put,
}

abstract class MyAnimeListManager {
  static const String webURL = 'https://myanimelist.net';
  static const String baseURL = 'https://api.myanimelist.net/v2';

  static final Auth auth = Auth(
    MyAnimeListSecrets.clientId,
    MyAnimeListSecrets.redirectURL,
  );

  static Future<void> initialize() async {
    final Map<dynamic, dynamic>? _token = DataStore.credentials.myanimelist;

    if (_token != null) {
      final TokenInfo token = TokenInfo.fromJson(_token);
      auth.token = token;

      if (auth.hasTokenExpired()) {
        try {
          auth.authenticateFromRefreshCode();
        } catch (_) {
          await auth.deleteToken();
        }
      }
    }
  }

  static Future<void> authenticate(final String code) async {
    await auth.authenticateFromCode(code);
    if (auth.token != null) {
      await auth.saveToken();
    }
  }

  static Future<String> request(
    final MyAnimeListRequestMethods method,
    final String url, [
    final Map<String, dynamic>? body,
  ]) async {
    if (!auth.isValidToken()) {
      throw StateError('Not logged in');
    }

    final Uri uri = Uri.parse('$baseURL$url');
    final Map<String, String> headers = <String, String>{
      'Authorization': '${auth.token!.tokenType} ${auth.token!.accessToken}',
    };

    if (body != null) {
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
    }

    final http.Response res;
    switch (method) {
      case MyAnimeListRequestMethods.get:
        res = await http.get(
          uri,
          headers: headers,
        );
        break;

      case MyAnimeListRequestMethods.post:
        res = await http.post(
          uri,
          body: QueryString.stringify(body!.cast<String, dynamic>()),
          headers: headers,
        );
        break;

      case MyAnimeListRequestMethods.put:
        res = await http.put(
          uri,
          body: QueryString.stringify(body!.cast<String, dynamic>()),
          headers: headers,
        );
        break;

      default:
        throw Error();
    }

    if (res.statusCode == 401) {
      await auth.authenticateFromRefreshCode();
      await auth.saveToken();
      return request(method, url, body);
    }

    return res.body;
  }

  bool get isLoggedIn => auth.isValidToken();
}
