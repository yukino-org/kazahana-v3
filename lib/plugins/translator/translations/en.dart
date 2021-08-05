import '../../../core/models/languages.dart';
import '../../../core/models/translations.dart';

class Sentences extends TranslationSentences {
  @override
  get code => LanguageCodes.en;

  @override
  home() => 'Home';

  @override
  search() => 'Search';

  @override
  settings() => 'Settings';

  @override
  episodes() => 'Episodes';

  @override
  episode() => 'Episode';

  @override
  noValidSources() => 'No valid sources were found.';

  @override
  prohibitedPage() => 'You shouldn\'t be here.';

  @override
  selectPlugin() => 'Select Plugin';

  @override
  searchInPlugin(plugin) => 'Search in $plugin';

  @override
  enterToSearch() => 'Enter something to search!';

  @override
  noResultsFound() => 'No results were found.';

  @override
  failedToGetResults() => 'No results were found.';

  @override
  preferences() => 'Preferences';

  @override
  landscapeVideoPlayer() => 'Landscape Video Player';

  @override
  landscapeVideoPlayerDetail() => 'Force auto-landscape when playing video';

  @override
  theme() => 'Theme';

  @override
  systemPreferredTheme() => 'System Preferred Theme';

  @override
  defaultTheme() => 'Default Theme';

  @override
  darkMode() => 'Dark Theme';

  @override
  close() => 'Close';

  @override
  chooseTheme() => 'Choose Theme';

  @override
  language() => 'Language';

  @override
  chooseLanguage() => 'Choose language';

  @override
  anime() => 'Anime';

  @override
  manga() => 'Manga';

  @override
  chapters() => 'Chapters';

  @override
  volumes() => 'Volumes';

  @override
  chapter() => 'Chapter';

  @override
  volume() => 'Volume';

  @override
  page() => 'Page';

  @override
  noPagesFound() => 'No valid pages were found.';

  @override
  vol() => 'Vol.';

  @override
  ch() => 'Ch.';

  @override
  mangaReaderDirection() => 'Manga Reader Direction';

  @override
  mangaReaderSwipeDirection() => 'Manga Reader Swipe Direction';

  @override
  horizontal() => 'Horizontal';

  @override
  vertical() => 'Vertical';

  @override
  leftToRight() => 'Left to Right';

  @override
  rightToLeft() => 'Right to Left';

  @override
  mangaReaderMode() => 'Manga Reader Mode';

  @override
  list() => 'List';

  @override
  previous() => 'Previous';

  @override
  next() => 'Next';

  @override
  skipIntro() => 'Skip Intro';

  @override
  skipIntroDuration() => 'Skip Intro Duration';

  @override
  seekDuration() => 'Seek Duration';

  @override
  seconds() => 'Seconds';

  @override
  autoPlay() => 'Auto Play';

  @override
  autoPlayDetail() => 'Starts playing the video automatically';

  @override
  autoNext() => 'Auto Next';

  @override
  autoNextDetail() =>
      'Starts playing the next video automatically after the current video';

  @override
  speed() => 'Speed';

  @override
  doubleTapToSwitchChapter() => 'Double Tap to Switch Chapters';

  @override
  doubleTapToSwitchChapterDetail() =>
      'Switches to previous or next chapter only when double clicked';

  @override
  tapAgainToSwitchPreviousChapter() => 'Tap again to go to previous chapter';

  @override
  tapAgainToSwitchNextChapter() => 'Tap again to go to next chapter';

  @override
  selectSource() => 'Select Source';

  @override
  sources() => 'Sources';
}
