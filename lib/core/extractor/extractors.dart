import 'animes/model.dart';
import 'animes/twistdoemot.dart' as twist_moe;

class Extractors {
  static Map<String, AnimeExtractor> anime = {'TwistMoe': twist_moe.TwistMoe()};
}
