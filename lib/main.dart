import 'dart:io' show Platform;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import './core/utils.dart' as utils;
import './plugins/state.dart' as state;
import './plugins/router.dart';
import './plugins/database/database.dart' show DataStore;
import './plugins/database/schemas/settings/settings.dart' as settings_schema;
import './plugins/translator/translator.dart';

void main() async {
  await DataStore.initialize();
  await state.AppState.initialize();
  Translator.trySetLanguage(Platform.localeName.split('_')[0]);

  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  bool useSystemPreferredTheme = true;
  bool useDarkMode = true;

  @override
  void initState() {
    super.initState();

    state.AppState.settings.subscribe(handleThemeChange);
  }

  @override
  void dispose() {
    state.AppState.settings.unsubscribe(handleThemeChange);

    super.dispose();
  }

  void handleThemeChange(settings_schema.SettingsSchema current,
      settings_schema.SettingsSchema previous) async {
    setState(() {
      useSystemPreferredTheme = current.useSystemPreferredTheme;
      useDarkMode = current.useDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yukino',
      navigatorKey: RouteManager.navigationKey,
      navigatorObservers: [RouteManager.keeper],
      theme: utils.Palette.lightTheme,
      darkTheme: utils.Palette.darkTheme,
      themeMode: useSystemPreferredTheme
          ? ThemeMode.system
          : (useDarkMode ? ThemeMode.dark : ThemeMode.light),
      initialRoute: RouteNames.initialRoute,
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == null) throw ('No route name was received');

        final route = RouteManager.routes.values.firstWhereOrNull((x) {
          if (x.alreadyHandled) return false;
          if (x.matcher != null) return x.matcher!(settings);
          return settings.name == x.route;
        });
        if (route == null) throw ('Invalid route: ${settings.name}');

        return MaterialPageRoute(
          builder: route.builder,
          settings: settings,
        );
      },
    );
  }
}
