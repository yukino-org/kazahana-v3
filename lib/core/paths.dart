import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;

abstract class Paths {
  static late final Directory docsDir;

  static Future<void> initialize() async {
    docsDir = await path_provider.getApplicationDocumentsDirectory();
  }
}

abstract class AssetPaths {
  static const String anilistLogo = 'assets/images/anilist_logo.png';
}
