import 'package:extensions/extensions.dart' as extensions;

abstract class ExtensionsManager {
  static Map<String, extensions.AnimeExtractor> animes =
      <String, extensions.AnimeExtractor>{};

  static Map<String, extensions.MangaExtractor> mangas =
      <String, extensions.MangaExtractor>{};

  static Future<void> initialize() async {}
}
