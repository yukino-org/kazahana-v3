import 'package:flutter/material.dart';
import '../../exports.dart';
import 'view.dart';

class HomePageRoute extends RoutePage {
  @override
  bool matches(final RouteInfo route) => route.name == routeName;

  @override
  Widget build(final RouteInfo route) => const HomePage();

  static const String routeName = '/';
}

extension HomePageRouteUtils on RoutePusher {
  Future<void> pushToViewPage() => navigator.pushNamed(HomePageRoute.routeName);
}
