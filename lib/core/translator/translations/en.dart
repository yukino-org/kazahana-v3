import 'package:utilx/locale.dart';
import 'model.dart';

class EnTranslation implements Translations {
  @override
  String anime() => 'Anime';

  @override
  String manga() => 'Manga';

  @override
  String searchAnime() => 'Search an anime';

  @override
  String searchManga() => 'Search a manga';

  @override
  final Locale locale = const Locale(LanguageCodes.en);
}
