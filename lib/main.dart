import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import './core/utils.dart' as utils;
import './plugins/state.dart' as state;
import './plugins/router.dart';

void main() => runApp(const App());

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  state.AppTheme currentTheme = state.AppTheme(true, true);

  @override
  void initState() {
    super.initState();

    state.AppState.darkMode.subscribe(handleThemeChange);
  }

  @override
  void dispose() {
    state.AppState.darkMode.unsubscribe(handleThemeChange);

    super.dispose();
  }

  void handleThemeChange(
      state.AppTheme current, state.AppTheme previous) async {
    setState(() {
      currentTheme = current;
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
      themeMode: currentTheme.systemPreferred
          ? ThemeMode.system
          : (currentTheme.darkMode ? ThemeMode.dark : ThemeMode.light),
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
