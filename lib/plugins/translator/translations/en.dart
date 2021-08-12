import '../../../core/models/languages.dart';
import '../../../core/models/translations.dart';

class Sentences extends TranslationSentences {
  @override
  final LanguageCodes code = LanguageCodes.en;

  @override
  String home() => 'Home';

  @override
  String search() => 'Search';

  @override
  String settings() => 'Settings';

  @override
  String episodes() => 'Episodes';

  @override
  String episode() => 'Episode';

  @override
  String noValidSources() => 'No valid sources were found.';

  @override
  String prohibitedPage() => "You shouldn't be here.";

  @override
  String selectPlugin() => 'Select Plugin';

  @override
  String searchInPlugin(final String plugin) => 'Search in $plugin';

  @override
  String enterToSearch() => 'Enter something to search!';

  @override
  String noResultsFound() => 'No results were found.';

  @override
  String failedToGetResults() => 'No results were found.';

  @override
  String preferences() => 'Preferences';

  @override
  String landscapeVideoPlayer() => 'Landscape Video Player';

  @override
  String landscapeVideoPlayerDetail() =>
      'Force auto-landscape when playing video';

  @override
  String theme() => 'Theme';

  @override
  String systemPreferredTheme() => 'System Preferred Theme';

  @override
  String defaultTheme() => 'Default Theme';

  @override
  String darkMode() => 'Dark Theme';

  @override
  String close() => 'Close';

  @override
  String chooseTheme() => 'Choose Theme';

  @override
  String language() => 'Language';

  @override
  String chooseLanguage() => 'Choose language';

  @override
  String anime() => 'Anime';

  @override
  String manga() => 'Manga';

  @override
  String chapters() => 'Chapters';

  @override
  String volumes() => 'Volumes';

  @override
  String chapter() => 'Chapter';

  @override
  String volume() => 'Volume';

  @override
  String page() => 'Page';

  @override
  String noPagesFound() => 'No valid pages were found.';

  @override
  String vol() => 'Vol.';

  @override
  String ch() => 'Ch.';

  @override
  String mangaReaderDirection() => 'Manga Reader Direction';

  @override
  String mangaReaderSwipeDirection() => 'Manga Reader Swipe Direction';

  @override
  String horizontal() => 'Horizontal';

  @override
  String vertical() => 'Vertical';

  @override
  String leftToRight() => 'Left to Right';

  @override
  String rightToLeft() => 'Right to Left';

  @override
  String mangaReaderMode() => 'Manga Reader Mode';

  @override
  String list() => 'List';

  @override
  String previous() => 'Previous';

  @override
  String next() => 'Next';

  @override
  String skipIntro() => 'Skip Intro';

  @override
  String skipIntroDuration() => 'Skip Intro Duration';

  @override
  String seekDuration() => 'Seek Duration';

  @override
  String seconds() => 'Seconds';

  @override
  String autoPlay() => 'Auto Play';

  @override
  String autoPlayDetail() => 'Starts playing the video automatically';

  @override
  String autoNext() => 'Auto Next';

  @override
  String autoNextDetail() =>
      'Starts playing the next video automatically after the current video';

  @override
  String speed() => 'Speed';

  @override
  String doubleTapToSwitchChapter() => 'Double Tap to Switch Chapters';

  @override
  String doubleTapToSwitchChapterDetail() =>
      'Switches to previous or next chapter only when double clicked';

  @override
  String tapAgainToSwitchPreviousChapter() =>
      'Tap again to go to previous chapter';

  @override
  String tapAgainToSwitchNextChapter() => 'Tap again to go to next chapter';

  @override
  String selectSource() => 'Select Source';

  @override
  String sources() => 'Sources';

  @override
  String refetch() => 'Refetch';
}
