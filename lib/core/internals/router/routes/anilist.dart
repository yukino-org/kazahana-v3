import '../../../anilist/exports.dart';
import '../route.dart';

class AnilistAuthRoute extends InternalRoute {
  @override
  bool matches(final String route) => route.startsWith(routeName);

  @override
  Future<void> handle(final String route) async {
    final AnilistToken token = AnilistToken.parseURL(route);
    await AnilistAuth.authenticate(token);
  }

  static const String routeName = '/anilist/auth';
}
