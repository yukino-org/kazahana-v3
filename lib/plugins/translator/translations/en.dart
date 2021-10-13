import 'package:utilx/utilities/languages.dart';
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

  @override
  String anilist() => 'AniList';

  @override
  String authenticating() => 'Authenticating';

  @override
  String successfullyAuthenticated() => 'Successfully authenticated!';

  @override
  String autoAnimeFullscreen() => 'Auto Anime Fullscreen';

  @override
  String autoAnimeFullscreenDetail() =>
      'Enter fullscreen by default when watching anime';

  @override
  String autoMangaFullscreen() => 'Auto Manga Fullscreen';

  @override
  String autoMangaFullscreenDetail() =>
      'Enter fullscreen by default when reading manga';

  @override
  String authenticationFailed() => 'Authenticated failed!';

  @override
  String connections() => 'Connections';

  @override
  String logIn() => 'Log In';

  @override
  String view() => 'View';

  @override
  String logOut() => 'Log Out';

  @override
  String nothingWasFoundHere() => 'Nothing was found here.';

  @override
  String progress() => 'Progress';

  @override
  String finishedOf(final int progress, final int? total) =>
      'Finished $progress of ${total ?? '?'}';

  @override
  String startedOn() => 'Started on';

  @override
  String completedOn() => 'Completed on';

  @override
  String edit() => 'Edit';

  @override
  String vols() => 'vols';

  @override
  String editing() => 'Editing';

  @override
  String save() => 'Save';

  @override
  String status() => 'Status';

  @override
  String noOfEpisodes() => 'No. of episodes';

  @override
  String noOfChapters() => 'No. of chapters';

  @override
  String noOfVolumes() => 'No. of volumes';

  @override
  String score() => 'Score';

  @override
  String repeat() => 'Repeat';

  @override
  String characters() => 'Characters';

  @override
  String play() => 'Play';

  @override
  String computedAs() => 'Computed as';

  @override
  String notThis() => 'Not this?';

  @override
  String selectAnAnime() => 'Select an anime!';

  @override
  String read() => 'Read';

  @override
  String animeSyncPercent() => 'Sync after Percentage';

  @override
  String extensions() => 'Extensions';

  @override
  String install() => 'Install';

  @override
  String uninstall() => 'Uninstall';

  @override
  String installing() => 'Installing';

  @override
  String uninstalling() => 'Uninstalling';

  @override
  String installed() => 'Installed';

  @override
  String by() => 'By';

  @override
  String cancel() => 'Cancel';

  @override
  String version() => 'Version';

  @override
  String topAnimes() => 'Top Animes';

  @override
  String recentlyUpdated() => 'Recently updated';

  @override
  String recommendedBy(final String by) => 'Recommended by $by';

  @override
  String seasonalAnimes() => 'Seasonal Animes';

  @override
  String selectAPluginToGetResults() => 'Select a plugin to get results';

  @override
  String initializing() => 'Initializing';

  @override
  String downloadingVersion(
    final String version,
    final String downloaded,
    final String total,
    final String percent,
  ) =>
      'Downloading $version ($downloaded / $total - $percent)';

  @override
  String unpackingVersion(final String version) => 'Unpacking $version';

  @override
  String restartingApp() => 'Restarting the app';

  @override
  String checkingForUpdates() => 'Checking for updates';

  @override
  String updatingToVersion(final String version) => 'Updating to $version';

  @override
  String failedToUpdate(final String err) => 'Failed to update: $err';

  @override
  String startingApp() => 'Starting app';

  @override
  String myAnimeList() => 'MyAnimeList';

  @override
  String episodesWatched() => 'Episodes watched';

  @override
  String chaptersRead() => 'Chapters read';

  @override
  String volumesCompleted() => 'Volumes completed';

  @override
  String nsfw() => 'NSFW';
}
