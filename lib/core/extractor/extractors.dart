import './animes/animeparadise_org.dart' as animeparadise_org;
import './animes/model.dart' show AnimeExtractor;
import './animes/twist_moe.dart' as twist_moe;
import './manga/mangadex_org.dart' as mangadex_org;
import './manga/model.dart' show MangaExtractor;
import './model.dart';

abstract class Extractors {
  static Map<String, AnimeExtractor> anime = mapName(<AnimeExtractor>[
    twist_moe.TwistMoe(),
    animeparadise_org.AnimePradiseOrg(),
  ]);

  static Map<String, MangaExtractor> manga = mapName(<MangaExtractor>[
    mangadex_org.MangaDex(),
  ]);
}
