import 'package:package_info_plus/package_info_plus.dart';
export 'package:package_info_plus/package_info_plus.dart' show PackageInfo;

abstract class Config {
  static const String name = 'Yukino';
  static const String protocol = 'yukino-app';
  static late PackageInfo pkg;

  static bool ready = false;

  static Future<void> initialize() async {
    pkg = await PackageInfo.fromPlatform();

    ready = true;
  }

  static String get code => pkg.appName;

  static String get version => pkg.version;
}

abstract class MiscSettings {
  static const Duration mouseOverlayDuration = Duration(seconds: 2);
  static const Duration cachedAnimeInfoExpireTime = Duration(days: 1);
  static const Duration cachedMangaInfoExpireTime = Duration(days: 1);
}