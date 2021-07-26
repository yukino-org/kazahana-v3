import '../model.dart';

class Sentences extends LanguageSentences {
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
}
