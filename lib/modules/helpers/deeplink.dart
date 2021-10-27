import 'package:uni_links/uni_links.dart' as uni_links;
import './protocol_handler.dart';
import '../../ui/router.dart';
import '../app/state.dart';

abstract class Deeplink {
  static String? link;
  static const List<String> prohibitedRoutes = <String>[
    RouteNames.initialRoute
  ];
  static bool hasHandledInitialLink = false;

  static Future<String?> getInitialLink() async {
    if (hasHandledInitialLink) {
      return null;
    }

    if (AppState.isMobile) {
      final String? link = await uni_links.getInitialLink();
      return link != null ? ProtocolHandler.parse(link) : null;
    }

    return link;
  }

  static void listen() {
    if (AppState.isMobile) {
      uni_links.linkStream.listen((final String? data) {
        if (data != null) {
          ProtocolHandler.handle(data);
        }
      });
    }
  }
}
