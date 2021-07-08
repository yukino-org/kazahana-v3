import 'package:flutter/material.dart';
import '../plugins/state.dart';
import '../pages/home/home.dart' as home_page;
import '../pages/search/search.dart' as search_page;
import '../pages/settings/settings.dart' as settings_page;

abstract class RouteNames {
  static const initialRoute = '/';

  static const home = '/';
  static const search = '/search';
  static const settings = '/settings';
}

class RouteInfo {
  final String route;
  final String name;
  final IconData icon;
  final WidgetBuilder builder;
  final bool isPublic;

  RouteInfo({
    required this.route,
    required this.name,
    required this.icon,
    required this.builder,
    required this.isPublic,
  });
}

class RouteKeeper extends NavigatorObserver {
  Route<dynamic>? currentRoute;
  final observer = SubscriberManager<Route<dynamic>?>();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRoute = currentRoute;
    observer.dispatch(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRoute = previousRoute;
    observer.dispatch(previousRoute, route);
  }
}

abstract class RouteManager {
  static String? currentRoute;
  static final navigationKey = GlobalKey<NavigatorState>();
  static final keeper = RouteKeeper();

  static final Map<String, RouteInfo> allRoutes = {
    RouteNames.home: RouteInfo(
      name: 'Home',
      route: RouteNames.home,
      icon: Icons.home,
      builder: (BuildContext context) => const home_page.Page(),
      isPublic: true,
    ),
    RouteNames.search: RouteInfo(
      name: 'Search',
      route: RouteNames.search,
      icon: Icons.search,
      builder: (BuildContext context) => const search_page.Page(),
      isPublic: true,
    ),
    RouteNames.settings: RouteInfo(
      name: 'Settings',
      route: RouteNames.settings,
      icon: Icons.settings,
      builder: (BuildContext context) => const settings_page.Page(),
      isPublic: true,
    ),
  };

  static final labeledRoutes =
      RouteManager.allRoutes.values.where((x) => x.isPublic).toList();
}
