import 'package:flutter/material.dart';
import 'package:utilx/utilities/utils.dart';
import './state.dart';
import '../../config/app.dart';
import '../../config/paths.dart';
import '../database/database.dart';
import '../extensions/extensions.dart';
import '../helpers/deeplink.dart';
import '../helpers/instance_manager.dart';
import '../helpers/logger.dart';
import '../helpers/protocol_handler.dart';
import '../helpers/screen.dart';
import '../local_server/server.dart';
import '../state/eventer.dart';
import '../trackers/trackers.dart';
import '../translator/translations.dart';
import '../translator/translator.dart';
import '../video_player/video_player.dart';

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
  static ErrorInfo? lastError;

  static final Eventer<AppLifecycleEvents> events =
      Eventer<AppLifecycleEvents>();

  static late final List<String> args;

  static Future<void> preinitialize(final List<String> args) async {
    AppLifecycle.args = args;

    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance!.addObserver(appLifecycleObserver);

    await Config.initialize();
    await PathDirs.initialize();
    await Logger.initialize();
    Logger.of('AppLifecycle').info('Starting "preinitialize"');

    if (AppState.isDesktop) {
      await LocalServer.initialize();
      Logger.of('LocalServer')
        ..info('Finished "initialize"')
        ..info('Serving at ${LocalServer.baseURL}');

      Screen.setTitle('${Config.name} v${Config.version}');
    }

    InstanceInfo? primaryInstance;
    primaryInstance = await InstanceManager.check();

    if (primaryInstance != null) {
      await InstanceManager.sendArguments(primaryInstance, args);
      Logger.of('InstanceManager').info('Finished "sendArguments"');

      await Screen.close();
      return;
    }

    await DatabaseManager.initialize();

    await AppState.initialize();
    Logger.of('AppState').info('Finished "initialize"');

    final TranslationSentences? settingsLocale =
        AppState.settings.value.preferences.locale != null
            ? Translator.tryGetTranslation(
                AppState.settings.value.preferences.locale!,
              )
            : null;
    if (settingsLocale == null) {
      AppState.settings.value.preferences.locale = null;
      await SettingsBox.save(AppState.settings.value);
    }

    Translator.t = settingsLocale ?? Translator.getSupportedTranslation();
    Deeplink.link = ProtocolHandler.fromArgs(args);
    preready = true;
    events.dispatch(AppLifecycleEvents.preready);
    Logger.of('AppLifecycle').info('Finished "preinitialize"');
  }

  static Future<void> initialize() async {
    await InstanceManager.register();
    Logger.of('InstanceManager').info('Finished "register"');

    await ProtocolHandler.register();
    Logger.of('ProtocolHandler').info('Finished "register"');

    await Screen.initialize();
    Logger.of('Screen').info('Finished "initialize"');

    await VideoPlayerManager.initialize();
    Logger.of('VideoPlayerManager').info('Finished "initialize"');

    await ExtensionsManager.initialize();
    Logger.of('ExtensionsManager').info('Finished "initialize"');

    await Trackers.initialize();
    Logger.of('Trackers').info('Finished "initialize"');

    ready = true;
    events.dispatch(AppLifecycleEvents.ready);
  }

  static Future<void> dispose() async {
    await LocalServer.dispose();
    Logger.of('LocalServer').info('Finished "dispose"');

    await DatabaseManager.dispose();
    Logger.of('DatabaseManager').info('Finished "dispose"');
  }

  static bool get failed => lastError != null;
}
