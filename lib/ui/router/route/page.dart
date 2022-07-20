import '../../../core/exports.dart';
import 'info.dart';

abstract class RoutePage {
  RouteTransitionsBuilder transitionBuilder = defaultTransitionBuilder;

  bool matches(final RouteInfo route);
  Widget build(final RouteInfo route);

  Route<dynamic> buildRoutePage(final RouteInfo route) =>
      defaultRoutePageBuilder(route: route, page: this);

  static Widget defaultTransitionBuilder(
    final BuildContext context,
    final Animation<double> animation,
    final Animation<double> secondaryAnimation,
    final Widget child,
  ) =>
      SharedAxisTransition(
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.scaled,
        child: child,
      );

  static Route<dynamic> defaultRoutePageBuilder({
    required final RouteInfo route,
    required final RoutePage page,
  }) =>
      PageRouteBuilder<dynamic>(
        settings: route.settings,
        pageBuilder: (final _, final __, final ___) => page.build(route),
        transitionDuration: AnimationDurations.defaultNormalAnimation,
        reverseTransitionDuration: AnimationDurations.defaultNormalAnimation,
        transitionsBuilder: RoutePage.defaultTransitionBuilder,
      );
}
