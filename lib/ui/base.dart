import 'package:flutter/material.dart';
import 'package:utilx/utilities/utils.dart';
import './pages/error_page/view.dart';
import './router.dart';
import '../config/app.dart';
import '../modules/app/lifecycle.dart';
import '../modules/app/state.dart';
import '../modules/database/database.dart';
import '../modules/helpers/ui.dart';
import '../modules/translator/translator.dart';

void Function()? _refreshFn;

class MainApp extends StatefulWidget {
  const MainApp({
    final Key? key,
  }) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();

  /// Always wrap this in `scheduleMicrotask` to avoid rebuild errors.
  static void refresh() {
    _refreshFn?.call();
  }
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();

    _refreshFn = () {
      setState(() {});
    };
  }

  @override
  void dispose() {
    _refreshFn = null;

    super.dispose();
  }

  @override
  Widget build(final BuildContext context) =>
      AppLifecycle.failed ? const _FailedApp() : const _SuccessApp();
}

class _SuccessApp extends StatefulWidget {
  const _SuccessApp({
    final Key? key,
  }) : super(key: key);

  @override
  _SuccessAppState createState() => _SuccessAppState();
}

class _SuccessAppState extends State<_SuccessApp> {
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
        title: Config.name,
        navigatorKey: RouteManager.navigationKey,
        navigatorObservers: <NavigatorObserver>[
          RouteManager.keeper,
          RouteManager.observer,
        ],
        theme: Palette.lightTheme,
        darkTheme: Palette.darkTheme,
        themeMode: themeMode,
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

  ThemeMode get themeMode =>
      AppState.settings.value.preferences.useSystemPreferredTheme
          ? ThemeMode.system
          : (AppState.settings.value.preferences.useDarkMode
              ? ThemeMode.dark
              : ThemeMode.light);
}

class _FailedApp extends StatelessWidget {
  const _FailedApp({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) => MaterialApp(
        title: '${Config.name} (Critical)',
        theme: Palette.errorTheme,
        home: ErrorPage(error: AppLifecycle.lastError!),
      );
}
