import 'package:flutter/material.dart';
import './plugins/routes.dart';
import './components/bottom_bar.dart';
import './core/utils.dart' as utils;

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: Navigator(
            key: RouteManager.navigationKey,
            observers: [RouteManager.keeper],
            initialRoute: RouteNames.initialRoute,
            onGenerateRoute: (RouteSettings settings) {
              if (settings.name == null) throw ('No route name was received');

              final route = RouteManager.allRoutes[settings.name];
              if (route == null) throw ('Invalid route: ${settings.name}');

              return MaterialPageRoute(
                  builder: route.builder, settings: settings);
            },
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: utils.remToPx(0.5),
              ),
            ]),
            child: const BottomBar(),
          ),
        ),
        onWillPop: () async {
          return !await RouteManager.navigationKey.currentState!.maybePop();
        });
  }
}
