import 'package:flutter/material.dart';
import './database/database.dart';
import './helpers/deeplink.dart';
import './helpers/eventer.dart';
import './helpers/instance_manager.dart';
import './helpers/local_server/server.dart';
import './helpers/logger.dart';
import './helpers/protocol_handler.dart';
import './helpers/screen.dart';
import './state.dart';
import './translator/translator.dart';
import './video_player/video_player.dart';
import '../config.dart';
import '../core/extensions.dart';
import '../core/models/translations.dart';
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

    Logger.of('AppLifecycle').info('Starting "preinitialize"');

    if (AppState.isDesktop) {
      try {
        await LocalServer.initialize();
        Logger.of('LocalServer')
          ..info('Finished "initialize"')
          ..info('Serving at ${LocalServer.baseURL}');
      } catch (err, trace) {
        Logger.of('LocalServer').error(
          '"initialize" failed: $err',
          trace,
        );
      }

      Screen.setTitle('${Config.name} v${Config.version}');
    }

    InstanceInfo? primaryInstance;
    try {
      primaryInstance = await InstanceManager.check();
    } catch (err, trace) {
      Logger.of('InstanceManager').error(
        '"check" failed: $err',
        trace,
      );
    }

    if (primaryInstance != null) {
      try {
        await InstanceManager.sendArguments(primaryInstance, args);
        Logger.of('InstanceManager').info('Finished "sendArguments"');
      } catch (err, trace) {
        Logger.of('InstanceManager').error(
          '"sendArguments" failed: $err',
          trace,
        );
      }

      await Screen.close();
      return;
    }

    try {
      await DataStore.initialize();
    } catch (err, trace) {
      Logger.of('DataStore').error(
        '"initialize" failed: $err',
        trace,
      );
    }

    final TranslationSentences? settingsLocale =
        DataStore.settings.locale != null
            ? Translator.tryGetTranslation(DataStore.settings.locale!)
            : null;
    if (settingsLocale == null) {
      DataStore.settings.locale = null;
      await DataStore.settings.save();
    }

    Translator.t = settingsLocale ?? Translator.getSupportedTranslation();
    Deeplink.link = ProtocolHandler.fromArgs(args);
    preready = true;
    events.dispatch(AppLifecycleEvents.preready);
    Logger.of('AppLifecycle').info('Finished "preinitialize"');
  }

  static Future<void> initialize() async {
    try {
      await InstanceManager.register();
      Logger.of('InstanceManager').info('Finished "register"');
    } catch (err, trace) {
      Logger.of('InstanceManager').error(
        '"register" failed: $err',
        trace,
      );
    }

    try {
      await AppState.initialize();
      Logger.of('AppState').info('Finished "initialize"');
    } catch (err, trace) {
      Logger.of('AppState').error(
        '"initialize" failed: $err',
        trace,
      );
    }

    try {
      await ProtocolHandler.register();
      Logger.of('ProtocolHandler').info('Finished "register"');
    } catch (err, trace) {
      Logger.of('ProtocolHandler').error(
        '"register" failed: $err',
        trace,
      );
    }

    try {
      await Screen.initialize();
      Logger.of('Screen').info('Finished "initialize"');
    } catch (err, trace) {
      Logger.of('Screen').error(
        '"initialize" failed: $err',
        trace,
      );
    }

    try {
      await VideoPlayer.initialize();
      Logger.of('player.initialize').info('Finished "initialize"');
    } catch (err, trace) {
      Logger.of('player.initialize').error(
        '"initialize" failed: $err',
        trace,
      );
    }

    try {
      await ExtensionsManager.initialize();
      Logger.of('ExtensionsManager').info('Finished "initialize"');
    } catch (err, trace) {
      Logger.of('ExtensionsManager').error(
        '"initialize" failed: $err',
        trace,
      );
    }

    try {
      await Trackers.initialize();
      Logger.of('Trackers').info('Finished "initialize"');
    } catch (err, trace) {
      Logger.of('Trackers').error(
        '"initialize" failed: $err',
        trace,
      );
    }

    ready = true;
    events.dispatch(AppLifecycleEvents.ready);
  }

  static Future<void> dispose() async {
    await LocalServer.dispose();
    Logger.of('LocalServer').info('Finished "dispose"');

    await DataStore.dispose();
    Logger.of('DataStore').info('Finished "dispose"');
  }
}
