import 'dart:convert';

import 'package:flutter/services.dart';

abstract class Config {
  static const String name = 'Yukino';
  static const String protocol = 'yukino-app';
  static late String code;
  static late String version;

  static bool ready = false;

  static Future<void> initialize() async {
    final String meta = await rootBundle.loadString('assets/data/meta.json');
    final Map<dynamic, dynamic> parsed =
        json.decode(meta) as Map<dynamic, dynamic>;

    code = parsed['code'] as String;
    version = parsed['version'] as String;

    ready = true;
  }

  static const String repoAuthor = 'yukino-app';
  static const String repoName = 'yukino';

  static const String storeURL =
      'https://raw.githubusercontent.com/$repoAuthor/extensions-store/dist/extensions.json';

  static const String releasesURL =
      'https://api.github.com/repos/$repoAuthor/$repoName/releases?per_page=20';
}

abstract class MiscSettings {
  static const Duration mouseOverlayDuration = Duration(seconds: 5);
  static const Duration cachedAnimeInfoExpireTime = Duration(days: 1);
  static const Duration cachedMangaInfoExpireTime = Duration(days: 1);
}
