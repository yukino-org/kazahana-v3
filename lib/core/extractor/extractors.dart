import './model.dart';
import './animes/model.dart' show AnimeExtractor;
import './animes/twist_moe.dart' as twist_moe;
import './animes/animeparadise_org.dart' as animeparadise_org;
import './manga/model.dart' show MangaExtractor;
import './manga/mangadex_org.dart' as mangadex_org;

abstract class Extractors {
  static Map<String, AnimeExtractor> anime = mapName([
    twist_moe.TwistMoe(),
    animeparadise_org.AnimePradiseOrg(),
  ]);

  static Map<String, MangaExtractor> manga = mapName([
    mangadex_org.MangaDex(),
  ]);
}
