import '../anilist/exports.dart';
import '../database/exports.dart';
import '../internals/exports.dart';
import '../paths.dart';
import '../tenka/exports.dart';
import '../translator/exports.dart';
import 'events.dart';

abstract class AppLoader {
  static bool ready = false;

  static Future<void> initialize() async {
    await Paths.initialize();
    await SettingsDatabase.initialize();
    await SecureDatabase.initialize();
    await CacheDatabase.initialize();
    await TenkaManager.initialize();
    await Translator.initialize();
    await AnilistAuth.initialize();
    ready = true;
    AppEvents.controller.add(AppEvent.initialized);
    initializeAfterLoad();
  }

  static Future<void> initializeAfterLoad() async {
    await Deeplink.initializeAfterLoad();
    AppEvents.controller.add(AppEvent.afterAnitialized);
  }
}
