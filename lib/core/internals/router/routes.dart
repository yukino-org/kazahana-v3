import '../../utils/exports.dart';
import 'route.dart';
import 'routes/exports.dart';

abstract class InternalRoutes {
  static AnilistAuthRoute anilistAuth = AnilistAuthRoute();

  static InternalRoute? findMatch(final String route) =>
      all.firstWhereOrNull((final InternalRoute x) => x.matches(route));

  static List<InternalRoute> get all => <InternalRoute>[anilistAuth];
}
