import 'dart:async';
import 'package:flutter/material.dart';
import './plugins/app_lifecycle.dart';
import './plugins/database/database.dart';
import './plugins/database/schemas/settings/settings.dart' as settings_schema;
import './plugins/helpers/logger.dart';
import './plugins/helpers/ui.dart';
import './plugins/router.dart';
import './plugins/state.dart';
import './plugins/translator/translator.dart';

Future<void> main(final List<String> args) async {
  try {
    await AppLifecycle.preinitialize(args);
    Logger.of('main').info('Completed "preinitialize"');
  } catch (err, trace) {
    Logger.of('main').error(
      '"preinitialize" failed: $err',
      trace,
    );
  }

  Logger.of('main').info('Starting "MainApp"');

  runZonedGuarded(() async {
    FlutterError.onError = (final FlutterErrorDetails details) {
      FlutterError.presentError(details);
      Logger.of('main').error(
        'Uncaught error: ${details.exceptionAsString()}',
        details.stack,
      );
    };

    runApp(const MainApp());
  }, (final Object error, final StackTrace stack) {
    Logger.of('main').error(
      'Uncaught error: ${error.toString()}',
      stack,
    );
  });
}

class MainApp extends StatefulWidget {
  const MainApp({
    final Key? key,
  }) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool useSystemPreferredTheme = DataStore.settings.useSystemPreferredTheme;
  bool useDarkMode = DataStore.settings.useDarkMode;

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
  }

  @override
  Widget build(final BuildContext context) => MaterialApp(
        title: 'Yukino',
        navigatorKey: RouteManager.navigationKey,
        navigatorObservers: <NavigatorObserver>[
          RouteManager.keeper,
          RouteManager.observer,
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

          final RouteInfo? route = RouteManager.tryGetRouteFromParsedRouteInfo(
            ParsedRouteInfo.fromSettings(settings),
          );
          if (route == null) {
            throw StateError('Invalid route: ${settings.name}');
          }

          return PageRouteBuilder<dynamic>(
            settings: settings,
            pageBuilder: (
              final BuildContext context,
              final Animation<double> a1,
              final Animation<double> a2,
            ) =>
                Directionality(
              textDirection: Translator.t.textDirection,
              child: route.builder(context),
            ),
            transitionsBuilder: (
              final BuildContext context,
              final Animation<double> a1,
              final Animation<double> a2,
              final Widget child,
            ) =>
                SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: a1,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: FadeTransition(
                opacity: a1,
                child: child,
              ),
            ),
          );
        },
      );
}
