import 'package:flutter/material.dart';
import '../../exports.dart';
import 'view.dart';

class SearchPageRoute extends RoutePage {
  @override
  bool matches(final RouteInfo route) => route.name == routeName;

  @override
  Widget build(final RouteInfo route) => const SearchPage();

  static const String routeName = '/search';
}

extension SearchPageRouteUtils on RoutePusher {
  Future<void> pushToSearchPage() =>
      navigator.pushNamed(SearchPageRoute.routeName);
}
