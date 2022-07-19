import '../../core/exports.dart';
import '../pages/home/route.dart';
import '../pages/search/route.dart';
import '../pages/view/route.dart';

class RouteInfo {
  const RouteInfo(this.settings);

  final RouteSettings settings;

  String get name => settings.name!;
  Object? get data => settings.arguments;
}

abstract class RoutePage {
  bool matches(final RouteInfo route);
  Widget build(final RouteInfo route);

  static Widget defaultTransitionBuilder(
    final BuildContext context,
    final Animation<double> animation,
    final Animation<double> secondaryAnimation,
    final Widget child,
  ) =>
      SharedAxisTransition(
        fillColor: Colors.transparent,
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.scaled,
        child: child,
      );
}

abstract class RoutePages {
  static final HomePageRoute home = HomePageRoute();
  static final SearchPageRoute search = SearchPageRoute();
  static final ViewPageRoute view = ViewPageRoute();

  static List<RoutePage> get all => <RoutePage>[
        home,
        search,
        view,
      ];
}
