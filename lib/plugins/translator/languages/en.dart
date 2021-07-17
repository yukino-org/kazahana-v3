import '../model.dart';

class Sentences extends LanguageSentences {
  @override
  get code => 'en';

  @override
  get language => 'English';

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
  selectPlugin() => 'Select plugin';

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
}
