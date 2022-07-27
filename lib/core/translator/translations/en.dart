import 'package:utilx/locale.dart';
import 'model.dart';

class EnTranslation implements Translations {
  @override
  String anime() => 'Anime';

  @override
  String manga() => 'Manga';

  @override
  String searchAnAnimeOrManga() => 'Search an anime or manga';

  @override
  String mostPopularAnimes() => 'Most Popular Animes';

  @override
  String topOngoingAnimes() => 'Top Ongoing Animes';

  @override
  String mostPopularMangas() => 'Most Popular Mangas';

  @override
  String topOngoingMangas() => 'Top Ongoing Mangas';

  @override
  String winter() => 'Winter';

  @override
  String spring() => 'Spring';

  @override
  String summer() => 'Summer';

  @override
  String fall() => 'Fall';

  @override
  String nEps(final String episodes) => '$episodes eps.';

  @override
  String nChs(final String chapters) => '$chapters chs.';

  @override
  String episodes() => 'Episodes';

  @override
  String chapters() => 'Chapters';

  @override
  String nMins(final String minutes) => '$minutes mins.';

  @override
  String nHrsNMins(final String hours, final String minutes) =>
      '$hours hrs. ${nMins(minutes)}';

  @override
  String relations() => 'Relations';

  @override
  String cancelled() => 'Cancelled';

  @override
  String releasing() => 'Releasing';

  @override
  String notYetReleased() => 'Unreleased';

  @override
  String finished() => 'Finished';

  @override
  String hiatus() => 'Hiatus';

  @override
  String nsfw() => 'NSFW';

  @override
  String characters() => 'Characters';

  @override
  String settings() => 'Settings';

  @override
  String appearance() => 'Appearance';

  @override
  String darkMode() => 'Dark Mode';

  @override
  String accentColor() => 'Accent Color';

  @override
  String backgroundColor() => 'Background Color';

  @override
  String disableAnimations() => 'Disable Animations';

  @override
  String useSystemTheme() => 'Use System Theme';

  @override
  String overview() => 'Overview';

  @override
  String extensions() => 'Extensions';

  @override
  String by(final String value) => 'By $value';

  @override
  String authenticatedAs(final String name) => 'Authenticated as $name';

  @override
  String anilist() => 'Anilist';

  @override
  String loginUsing(final String name) => 'Login using $name';

  @override
  String somethingWentWrong() => 'Something went wrong!';

  @override
  String trackYourProgressUsingAnilist() =>
      'Track your progress using Anilist!';

  @override
  String current() => 'Current';

  @override
  String planning() => 'Planning';

  @override
  String completed() => 'Completed';

  @override
  String dropped() => 'Dropped';

  @override
  String paused() => 'Paused';

  @override
  String repeating() => 'Repeating';

  @override
  String totalAnime() => 'Total Anime';

  @override
  String episodesWatched() => 'Episodes Watched';

  @override
  String meanScore() => 'Mean Score';

  @override
  String timeSpent() => 'Time Spent';

  @override
  String totalManga() => 'Total Manga';

  @override
  String chaptersRead() => 'Chapters Read';

  @override
  String volumesRead() => 'Volumes Read';

  @override
  final Locale locale = const Locale(LanguageCodes.en);
}
