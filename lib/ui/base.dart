import '../core/exports.dart';
import 'router/exports.dart';

class BaseApp extends StatelessWidget {
  const BaseApp({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) => MaterialApp(
        title: AppMeta.name,
        theme: Themer.defaultThemeData,
        onGenerateRoute: (final RouteSettings settings) {
          final RouteInfo route = RouteInfo(settings);
          final RoutePage? page = RoutePages.all.firstWhereOrNull(
            (final RoutePage x) => x.matches(route),
          );
          if (page == null) return null;
          return PageRouteBuilder<dynamic>(
            settings: settings,
            pageBuilder: (final _, final __, final ___) => page.build(route),
            transitionDuration: AnimationDurations.defaultNormalAnimation,
            reverseTransitionDuration:
                AnimationDurations.defaultNormalAnimation,
            transitionsBuilder: RoutePage.defaultTransitionBuilder,
          );
        },
      );
}
