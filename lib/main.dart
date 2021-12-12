import 'dart:async';
import 'package:flutter/material.dart';
import 'package:utilx/utilities/utils.dart';
import './modules/app/lifecycle.dart';
import './modules/app/state.dart';
import './modules/database/database.dart';
import './modules/helpers/logger.dart';
import './modules/helpers/ui.dart';
import './modules/translator/translator.dart';
import './ui/router.dart';

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
    final SettingsSchema current,
    final SettingsSchema previous,
  ) {
    final Map<dynamic, dynamic> changables = <dynamic, dynamic>{
      current.preferences.useSystemPreferredTheme:
          previous.preferences.useSystemPreferredTheme,
      current.preferences.useDarkMode: previous.preferences.useDarkMode,
    };

    if (changables.entries
        .toList()
        .some((final MapEntry<dynamic, dynamic> x) => x.key != x.value)) {
      setState(() {});
    }
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
        themeMode: AppState.settings.value.preferences.useSystemPreferredTheme
            ? ThemeMode.system
            : (AppState.settings.value.preferences.useDarkMode
                ? ThemeMode.dark
                : ThemeMode.light),
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
