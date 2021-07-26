import 'package:flutter/material.dart';
import '../plugins/state.dart';
import '../plugins/translator/translator.dart';
import '../pages/stacked_home_page/stacked_home_page.dart' as stacked_home_page;
import '../pages/home_page/home_page.dart' as home_page;
import '../pages/search_page/search_page.dart' as search_page;
import '../pages/settings_page/settings_page.dart' as settings_page;
import '../pages/anime_page/anime_page.dart' as anime_page;
import '../pages/manga_page/manga_page.dart' as manga_page;

abstract class RouteNames {
  static const initialRoute = '/';

  static const homeHandler = '/';
  static const home = '/home';
  static const search = '/search';
  static const settings = '/settings';
  static const animePage = '/anime_page';
  static const mangaPage = '/manga_page';
}

class RouteInfo {
  final String route;
  final String Function()? name;
  final IconData? icon;
  final WidgetBuilder builder;
  final bool isPublic;
  final bool alreadyHandled;
  final bool Function(RouteSettings settings)? matcher;

  RouteInfo({
    required this.route,
    this.name,
    this.icon,
    required this.builder,
    this.isPublic = false,
    this.alreadyHandled = false,
    this.matcher,
  }) {
    if (isPublic) {
      if (icon == null) {
        throw ('Public route ($route) didn\'t have an \'icon\'');
      }
      if (name == null) {
        throw ('Public route ($route) didn\'t have an \'name\'');
      }
    }

    if (alreadyHandled && matcher != null) {
      throw ('Already handled route can\'t have \'matcher\'');
    }
  }
}

class RouteKeeper extends NavigatorObserver {
  Route<dynamic>? currentRoute;
  final observer = SubscriberManager<Route<dynamic>?>();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRoute = route;
    observer.dispatch(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRoute = previousRoute;
    observer.dispatch(previousRoute, route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    currentRoute = newRoute;
    observer.dispatch(newRoute, oldRoute);
  }
}

class ParsedRouteInfo {
  final String route;
  final Map<String, String> params;

  ParsedRouteInfo(this.route, this.params);

  @override
  String toString() => '$route?${RouteManager.makeUrlParams(params)}';
}

abstract class RouteManager {
  static final navigationKey = GlobalKey<NavigatorState>();
  static final keeper = RouteKeeper();
  static final Map<String, RouteInfo> routes = {
    RouteNames.home: RouteInfo(
      name: Translator.t.home,
      route: RouteNames.home,
      icon: Icons.home,
      builder: (BuildContext context) => const home_page.Page(),
      isPublic: true,
      alreadyHandled: true,
    ),
    RouteNames.search: RouteInfo(
      name: Translator.t.search,
      route: RouteNames.search,
      icon: Icons.search,
      builder: (BuildContext context) => const search_page.Page(),
      isPublic: true,
      alreadyHandled: true,
    ),
    RouteNames.settings: RouteInfo(
      name: Translator.t.settings,
      route: RouteNames.settings,
      icon: Icons.settings,
      builder: (BuildContext context) => const settings_page.Page(),
      isPublic: true,
    ),
    RouteNames.animePage: RouteInfo(
      route: RouteNames.animePage,
      builder: (BuildContext context) => const anime_page.Page(),
    ),
    RouteNames.mangaPage: RouteInfo(
      route: RouteNames.mangaPage,
      builder: (BuildContext context) => const manga_page.Page(),
    ),
    RouteNames.homeHandler: RouteInfo(
      route: RouteNames.homeHandler,
      builder: (BuildContext context) => const stacked_home_page.Page(),
      matcher: (settings) =>
          settings.name?.startsWith(RouteNames.homeHandler) ?? false,
    ),
  };

  static List<RouteInfo> get labeledRoutes =>
      routes.values.where((x) => x.isPublic).toList();

  static String getOnlyRoute(String route) => route.split('?')[0];

  static ParsedRouteInfo parseRoute(String route) {
    final split = route.split('?');
    return ParsedRouteInfo(
      split[0],
      parseUrlParams(split.length > 1 ? split[1] : ''),
    );
  }

  static Map<String, String> parseUrlParams(String queries) {
    final Map<String, String> params = {};
    queries.split('&').forEach((x) {
      final kv = x.split('=');
      if (kv.length == 2) {
        params[kv[0]] = Uri.decodeComponent(kv[1]);
      }
    });
    return params;
  }

  static String makeUrlParams(Map<String, String> queries) {
    List<String> params = [];
    queries.forEach((k, v) {
      params.add('$k=$v');
    });
    return params.join('&');
  }
}
