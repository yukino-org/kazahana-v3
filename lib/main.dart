import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import './components/player/player.dart' as player show initialize;
import './config.dart';
import './core/models/languages.dart' show LanguageName;
import './core/trackers/trackers.dart';
import './plugins/app_lifecycle_observer.dart';
import './plugins/database/database.dart' show DataStore;
import './plugins/database/schemas/settings/settings.dart' as settings_schema;
import './plugins/helpers/instance_manager.dart';
import './plugins/helpers/local_server/server.dart';
import './plugins/helpers/logger.dart';
import './plugins/helpers/protocol_handler.dart';
import './plugins/helpers/screen.dart';
import './plugins/helpers/ui.dart';
import './plugins/router.dart';
import './plugins/state.dart';
import './plugins/translator/translator.dart';

Future<void> main(final List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance!.addObserver(appLifecycleObserver);

  await Config.initialize();
  await Logger.initialize();

  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    await LocalServer.initialize();
    Logger.info('Local server serving at ${LocalServer.baseURL}');

    WindowManager.instance.setTitle('${Config.name} v${Config.version}');
  }

  final InstanceInfo? primaryInstance = await InstanceManager.check();
  if (primaryInstance != null &&
      await InstanceManager.sendArguments(primaryInstance, args)) {
    await WindowManager.instance.terminate();
    return;
  }

  await InstanceManager.register();
  await ProtocolHandler.register();
  await DataStore.initialize();
  await AppState.initialize();
  await Screen.initialize();
  Translator.setLanguage(
    AppState.settings.current.locale != null &&
            Translator.isSupportedLocale(
              AppState.settings.current.locale!,
            )
        ? AppState.settings.current.locale!
        : Translator.getSupportedLocale(),
  );

  await player.initialize();
  await Trackers.initialize();

  AppState.afterInitialRoute = ProtocolHandler.parse(args);

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({
    final Key? key,
  }) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool useSystemPreferredTheme =
      AppState.settings.current.useSystemPreferredTheme;
  bool useDarkMode = AppState.settings.current.useDarkMode;

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
                route.builder(context),
            transitionsBuilder: (
              final BuildContext context,
              final Animation<double> a1,
              final Animation<double> a2,
              final Widget child,
            ) =>
                SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: const Offset(0, 0),
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
