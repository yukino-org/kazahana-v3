import 'package:uni_links/uni_links.dart' as uni_links;
import '../../ui/exports.dart';
import '../app/exports.dart';
import '../packages.dart';
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
    String resolvedPath = path;
    if (resolvedPath.startsWith(fullScheme)) {
      resolvedPath = resolvedPath.replaceFirst(fullScheme, '');
    }
    debugPrint('Incoming deeplink: $resolvedPath');

    final InternalRoute? internalRoute = InternalRoutes.findMatch(resolvedPath);
    if (internalRoute != null) {
      internalRoute.handle(resolvedPath);
      return;
    }
    gNavigatorKey.currentState!.pushNamed(resolvedPath);
  }

  static const String fullScheme = '${AppMeta.scheme}://';
}
