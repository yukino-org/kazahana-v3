import 'package:flutter/material.dart';
import './database/database.dart';
import './helpers/eventer.dart';
import './helpers/instance_manager.dart';
import './helpers/local_server/server.dart';
import './helpers/logger.dart';
import './helpers/protocol_handler.dart';
import './helpers/screen.dart';
import './helpers/utils/string.dart';
import './state.dart';
import './translator/translator.dart';
import '../components/player/player.dart' as player show initialize;
import '../config.dart';
import '../core/extensions.dart';
import '../core/trackers/trackers.dart';

// TODO: Pending at https://github.com/flutter/flutter/issues/30735
class _AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    // TODO: Save window state in desktop
  }
}

final _AppLifecycleObserver appLifecycleObserver = _AppLifecycleObserver();

enum AppLifecycleEvents {
  preready,
  ready,
}

abstract class AppLifecycle {
  static bool preready = false;
  static bool ready = false;
  static final Eventer<AppLifecycleEvents> events =
      Eventer<AppLifecycleEvents>();

  static late final List<String> args;

  static Future<void> preinitialize(final List<String> args) async {
    AppLifecycle.args = args;

    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance!.addObserver(appLifecycleObserver);

    await Config.initialize();
    await Logger.initialize();
    Logger.of(AppLifecycle)
        .info('Starting ${StringUtils.type(AppLifecycle.preinitialize)}');

    if (AppState.isDesktop) {
      await LocalServer.initialize();

      Screen.setTitle('${Config.name} v${Config.version}');
    }

    final InstanceInfo? primaryInstance = await InstanceManager.check();
    if (primaryInstance != null &&
        await InstanceManager.sendArguments(primaryInstance, args)) {
      await Screen.close();
      return;
    }

    await DataStore.initialize();

    Translator.setLanguage(
      DataStore.settings.locale != null &&
              Translator.isSupportedLocale(
                DataStore.settings.locale!,
              )
          ? DataStore.settings.locale!
          : Translator.getSupportedLocale(),
    );

    AppState.launchRoute = ProtocolHandler.parse(args);
    preready = true;
    events.dispatch(AppLifecycleEvents.preready);
    Logger.of(AppLifecycle)
        .info('Finished ${StringUtils.type(AppLifecycle.preinitialize)}');
  }

  static Future<void> initialize() async {
    await InstanceManager.register();
    await AppState.initialize();
    await ProtocolHandler.register();
    await Screen.initialize();
    await player.initialize();
    await ExtensionsManager.initialize();
    await Trackers.initialize();

    preready = false;
    events.dispatch(AppLifecycleEvents.ready);
  }
}
