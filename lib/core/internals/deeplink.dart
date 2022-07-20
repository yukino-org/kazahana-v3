import 'package:uni_links/uni_links.dart' as uni_links;
import '../../ui/exports.dart';
import 'router/exports.dart';

abstract class Deeplink {
  static Future<void> initializeAfterLoad() async {
    final String? path = await uni_links.getInitialLink();
    if (path != null) handle(path);
    listen();
  }

  static void listen() {
    uni_links.linkStream.listen((final String? path) {
      if (path == null) return;
      handle(path);
    });
  }

  static void handle(final String path) {
    final InternalRoute? internalRoute = InternalRoutes.findMatch(path);
    if (internalRoute != null) {
      internalRoute.handle(path);
      return;
    }
    navigationKey.currentState!.pushNamed(path);
  }
}
