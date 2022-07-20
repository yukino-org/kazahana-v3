import 'package:anilist/anilist.dart';
import '../app/exports.dart';
import '../database/exports.dart';
import 'credentials.dart';

abstract class AnilistAuth {
  static const String baseURL = 'https://anilist.co/api/v2';

  static Future<void> initialize() async {
    AnilistGraphQL.updateClient(
      token: SecureDatabase.data.anilistToken,
      onTokenExpired: unauthenticate,
      additionalHeaders: const <String, String>{
        'User-Agent': '${AppMeta.name} v${AppMeta.version}',
      },
    );
  }

  static Future<void> authenticate(final AnilistToken token) async {
    SecureDatabase.data.anilistToken = token;
    await SecureDatabase.save();
  }

  static Future<void> unauthenticate() async {
    SecureDatabase.data.anilistToken = null;
    await SecureDatabase.save();
  }

  static String get oauthURL => Uri.encodeFull(
        '$baseURL/oauth/authorize?client_id=${AnilistCredentials.clientId}&response_type=token',
      );
}
