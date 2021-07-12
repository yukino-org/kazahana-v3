import 'package:flutter/material.dart';
import '../plugins/state.dart';
import '../pages/splash_screen/splash_screen.dart' as splash_screen;
import '../pages/stacked_home_page/stacked_home_page.dart' as stacked_home_page;
import '../pages/home_page/home_page.dart' as home_page;
import '../pages/search_page/search_page.dart' as search_page;
import '../pages/settings_page/settings_page.dart' as settings_page;
import '../pages/anime_page/anime_page.dart' as anime_page;
import '../pages/watch_page/watch_page.dart' as watch_page;

abstract class RouteNames {
  static const initialRoute = '/';

  static const splashScreen = '/';
  static const homeHandler = '/home';
  static const home = '/home/home';
  static const search = '/home/search';
  static const settings = '/settings';
  static const animePage = '/anime_page';
  static const watchPage = '/watch_page';
}

class RouteInfo {
  final String route;
  final String? name;
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

abstract class RouteManager {
  static final navigationKey = GlobalKey<NavigatorState>();
  static final keeper = RouteKeeper();
  static final Map<String, RouteInfo> routes = {
    RouteNames.splashScreen: RouteInfo(
      route: RouteNames.splashScreen,
      builder: (BuildContext context) => const splash_screen.Screen(),
    ),
    RouteNames.homeHandler: RouteInfo(
      route: RouteNames.homeHandler,
      builder: (BuildContext context) => const stacked_home_page.Page(),
      matcher: (settings) =>
          settings.name?.startsWith(RouteNames.homeHandler) ?? false,
    ),
    RouteNames.home: RouteInfo(
      name: 'Home',
      route: RouteNames.home,
      icon: Icons.home,
      builder: (BuildContext context) => const home_page.Page(),
      isPublic: true,
      alreadyHandled: true,
    ),
    RouteNames.search: RouteInfo(
      name: 'Search',
      route: RouteNames.search,
      icon: Icons.search,
      builder: (BuildContext context) => const search_page.Page(),
      isPublic: true,
      alreadyHandled: true,
    ),
    RouteNames.settings: RouteInfo(
      name: 'Settings',
      route: RouteNames.settings,
      icon: Icons.settings,
      builder: (BuildContext context) => const settings_page.Page(),
      isPublic: true,
    ),
    RouteNames.animePage: RouteInfo(
      route: RouteNames.animePage,
      builder: (BuildContext context) => const anime_page.Page(),
    ),
    RouteNames.watchPage: RouteInfo(
      route: RouteNames.watchPage,
      builder: (BuildContext context) => const watch_page.Page(),
    ),
  };

  static List<RouteInfo> get labeledRoutes =>
      routes.values.where((x) => x.isPublic).toList();
}
