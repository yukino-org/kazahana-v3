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
          final RoutePage? page = RoutePages.findMatch(route);
          if (page == null) return null;
          return page.buildRoutePage(route);
        },
      );
}
