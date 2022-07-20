import '../core/exports.dart';
import 'router/exports.dart';

class BaseApp extends StatefulWidget {
  const BaseApp({
    final Key? key,
  }) : super(key: key);

  @override
  State<BaseApp> createState() => _BaseAppState();
}

class _BaseAppState extends State<BaseApp> {
  late ThemerThemeData theme;

  @override
  void initState() {
    super.initState();

    theme = Themer.defaultTheme();
    SettingsDatabase.onChange.listen((final SettingsSchema settings) {
      final ThemerThemeData nTheme = Themer.getCurrentTheme();
      if (theme != nTheme) {
        setState(() {
          theme = nTheme;
        });
      }
    });
  }

  @override
  Widget build(final BuildContext context) => MaterialApp(
        title: AppMeta.name,
        theme: theme.asThemeData,
        onGenerateRoute: (final RouteSettings settings) {
          final RouteInfo route = RouteInfo(settings);
          final RoutePage? page = RoutePages.findMatch(route);
          if (page == null) return null;
          return page.buildRoutePage(route);
        },
      );
}
