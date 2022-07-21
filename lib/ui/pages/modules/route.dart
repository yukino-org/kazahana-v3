import 'package:flutter/material.dart';
import '../../exports.dart';
import 'view.dart';

class ModulesPageRoute extends RoutePage {
  @override
  bool matches(final RouteInfo route) => route.name == routeName;

  @override
  Widget build(final RouteInfo route) => const ModulesPage();

  static const String routeName = '/modules';
}

extension ModulesPageRouteUtils on RoutePusher {
  Future<void> pushToModulesPage() => navigator.pushNamed(ModulesPageRoute.routeName);
}
