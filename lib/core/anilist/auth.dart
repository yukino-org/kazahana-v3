import 'package:anilist/anilist.dart';
import 'package:kazahana/ui/exports.dart';
import '../app/exports.dart';
import '../database/exports.dart';
import '../packages.dart';
import 'credentials.dart';

abstract class AnilistAuth {
  static const String baseURL = 'https://anilist.co/api/v2';
  static AnilistUser? user;

  static Future<void> initialize() async {
    updateAnilistClient(SecureDatabase.data.anilistToken);
    await fetchUser();
  }

  static Future<void> authenticate(final AnilistToken token) async {
    SecureDatabase.data.anilistToken = token;
    await SecureDatabase.save();
    updateAnilistClient(SecureDatabase.data.anilistToken);

    await fetchUser();
    if (user != null) {
      Toast(
        content: Text(
          <String>[
            '${gNavigatorKey.currentContext!.t.anilist()}:',
            gNavigatorKey.currentContext!.t.authenticatedAs(user!.name),
          ].join(' '),
        ),
      ).show();
    }
  }

  static Future<void> unauthenticate() async {
    SecureDatabase.data.anilistToken = null;
    await SecureDatabase.save();
    updateAnilistClient(null);
  }

  static Future<void> fetchUser() async {
    try {
      user = await AnilistUserEndpoints.getAuthenticatedUser();
    } catch (_) {}
  }

  static void updateAnilistClient(final AnilistToken? token) {
    AnilistGraphQL.updateClient(
      token: token,
      onTokenExpired: token != null ? unauthenticate : null,
      additionalHeaders: const <String, String>{
        'User-Agent': '${AppMeta.name} v${AppMeta.version}',
      },
    );
    AppEvents.controller.add(AppEvent.anilistStateChange);
  }

  static String get oauthURL => Uri.encodeFull(
        '$baseURL/oauth/authorize?client_id=${AnilistCredentials.clientId}&response_type=token',
      );
}
