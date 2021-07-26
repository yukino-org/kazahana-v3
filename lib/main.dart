import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import './core/utils.dart' as utils;
import './plugins/state.dart' as state;
import './plugins/router.dart';
import './plugins/database/database.dart' show DataStore;
import './plugins/database/schemas/settings/settings.dart' as settings_schema;
import './plugins/translator/translator.dart';
import './plugins/translator/model.dart' show LanguageName;

void main() async {
  await DataStore.initialize();
  await state.AppState.initialize();
  Translator.setLanguage(
    state.AppState.settings.current.locale != null &&
            Translator.isSupportedLocale(
              state.AppState.settings.current.locale!,
            )
        ? state.AppState.settings.current.locale!
        : Translator.getSupportedLocale(),
  );

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

    state.AppState.settings.subscribe(handleSettingsChange);
  }

  @override
  void dispose() {
    state.AppState.settings.unsubscribe(handleSettingsChange);

    super.dispose();
  }

  void handleSettingsChange(
    final settings_schema.SettingsSchema current,
    final settings_schema.SettingsSchema previous,
  ) async {
    setState(() {
      useSystemPreferredTheme = current.useSystemPreferredTheme;
      useDarkMode = current.useDarkMode;
    });

    if (current.locale != null && current.locale != Translator.t.code.code) {
      Translator.setLanguage(current.locale!);
    }
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
          return RouteManager.getOnlyRoute(settings.name!) == x.route;
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
