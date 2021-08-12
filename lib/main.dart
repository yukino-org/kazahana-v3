import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import './core/models/languages.dart' show LanguageName;
import './plugins/database/database.dart' show DataStore;
import './plugins/database/schemas/settings/settings.dart' as settings_schema;
import './plugins/helpers/ui.dart';
import './plugins/router.dart';
import './plugins/state.dart';
import './plugins/translator/translator.dart';

Future<void> main() async {
  await DataStore.initialize();
  await AppState.initialize();
  Translator.setLanguage(
    AppState.settings.current.locale != null &&
            Translator.isSupportedLocale(
              AppState.settings.current.locale!,
            )
        ? AppState.settings.current.locale!
        : Translator.getSupportedLocale(),
  );

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({
    final Key? key,
  }) : super(key: key);

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  bool useSystemPreferredTheme = true;
  bool useDarkMode = true;

  @override
  void initState() {
    super.initState();

    AppState.settings.subscribe(handleSettingsChange);
  }

  @override
  void dispose() {
    AppState.settings.unsubscribe(handleSettingsChange);

    super.dispose();
  }

  void handleSettingsChange(
    final settings_schema.SettingsSchema current,
    final settings_schema.SettingsSchema previous,
  ) {
    setState(() {
      useSystemPreferredTheme = current.useSystemPreferredTheme;
      useDarkMode = current.useDarkMode;
    });

    if (current.locale != null && current.locale != Translator.t.code.code) {
      Translator.setLanguage(current.locale!);
    }
  }

  @override
  Widget build(final BuildContext context) => MaterialApp(
        title: 'Yukino',
        navigatorKey: RouteManager.navigationKey,
        navigatorObservers: <NavigatorObserver>[
          RouteManager.keeper,
        ],
        theme: Palette.lightTheme,
        darkTheme: Palette.darkTheme,
        themeMode: useSystemPreferredTheme
            ? ThemeMode.system
            : (useDarkMode ? ThemeMode.dark : ThemeMode.light),
        initialRoute: RouteNames.initialRoute,
        onGenerateRoute: (final RouteSettings settings) {
          if (settings.name == null) {
            throw StateError('No route name was received');
          }

          final RouteInfo? route =
              RouteManager.routes.values.firstWhereOrNull((final RouteInfo x) {
            if (x.alreadyHandled) return false;
            if (x.matcher != null) return x.matcher!(settings);
            return RouteManager.getOnlyRoute(settings.name!) == x.route;
          });
          if (route == null) {
            throw StateError('Invalid route: ${settings.name}');
          }

          return MaterialPageRoute<dynamic>(
            builder: route.builder,
            settings: settings,
          );
        },
      );
}
