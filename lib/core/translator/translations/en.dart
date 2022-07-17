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
  String mostPopularAnimes() => 'Most Popular Animes';

  @override
  String topOngoingAnimes() => 'Top Ongoing Animes';

  @override
  String mostPopularMangas() => 'Most Popular Mangas';

  @override
  String topOngoingMangas() => 'Top Ongoing Mangas';

  @override
  String current() => 'Ongoing';

  @override
  String finished() => 'Finished';

  @override
  String tba() => 'TBA';

  @override
  String unreleased() => 'Unreleased';

  @override
  String upcoming() => 'Upcoming';

  @override
  String winter() => 'Winter';

  @override
  String spring() => 'Spring';

  @override
  String summer() => 'Summer';

  @override
  String autumn() => 'Autumn';

  @override
  final Locale locale = const Locale(LanguageCodes.en);
}
