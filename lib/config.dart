import 'package:package_info_plus/package_info_plus.dart';

export 'package:package_info_plus/package_info_plus.dart' show PackageInfo;

abstract class Config {
  static const String productName = 'Yukino';

  static Future<PackageInfo> pkg() => PackageInfo.fromPlatform();
}
