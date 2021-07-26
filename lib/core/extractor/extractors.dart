import './model.dart';
import './animes/model.dart';
import './animes/twist_moe.dart' as twist_moe;
import './manga/model.dart';
import './manga/mangadex_org.dart' as mangadex_org;

Map<String, T> _mapName<T extends BaseExtractor>(final List<T> items) =>
    items.asMap().map((key, value) => MapEntry(value.name, value));

abstract class Extractors {
  static Map<String, AnimeExtractor> anime = _mapName([
    twist_moe.TwistMoe(),
  ]);

  static Map<String, MangaExtractor> manga = _mapName([
    mangadex_org.MangaDex(),
  ]);
}
