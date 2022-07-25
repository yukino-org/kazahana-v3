import '../core/exports.dart';
import 'exports.dart';

class BaseApp extends StatefulWidget {
  const BaseApp({
    super.key,
  });

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
        scaffoldMessengerKey: gScaffoldMessengerKey,
        navigatorKey: gNavigatorKey,
        builder: (
          final BuildContext context,
          final Widget? child,
        ) =>
            RelativeSize(
          data: RelativeSizeData.fromContext(context),
          child: Builder(
            builder: (final BuildContext context) => Theme(
              data: theme.getThemeData(context),
              child: child!,
            ),
          ),
        ),
        onGenerateRoute: (final RouteSettings settings) {
          final RouteInfo route = RouteInfo(settings);
          final RoutePage? page = RoutePages.findMatch(route);
          if (page == null) return null;
          return page.buildRoutePage(route);
        },
      );
}
