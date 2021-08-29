import 'package:hive/hive.dart';
import '../../../../core/models/player.dart';
import '../../database.dart';

part 'settings.g.dart';

const bool _useSystemPreferredTheme = true;
const bool _useDarkMode = false;
const bool _fullscreenVideoPlayer = false;
const String? _locale = null;
const MangaDirections _mangaReaderDirection = MangaDirections.leftToRight;
const MangaSwipeDirections _mangaReaderSwipeDirection =
    MangaSwipeDirections.horizontal;
const MangaMode _mangaReaderMode = MangaMode.page;
const int _introDuration = Player.defaultIntroLength;
const int _seekDuration = Player.defaultSeekLength;
const int _volume = Player.maxVolume;
const bool _autoNext = false;
const bool _autoPlay = false;
const bool _doubleClickSwitchChapter = true;
const bool _animeAutoFullscreen = true;
const bool _mangaAutoFullscreen = true;

@HiveType(typeId: TypeIds.settings)
class SettingsSchema extends HiveObject {
  SettingsSchema({
    final this.useSystemPreferredTheme = _useSystemPreferredTheme,
    final this.useDarkMode = _useDarkMode,
    final this.fullscreenVideoPlayer = _fullscreenVideoPlayer,
    final this.locale = _locale,
    final this.mangaReaderDirection = _mangaReaderDirection,
    final this.mangaReaderSwipeDirection = _mangaReaderSwipeDirection,
    final this.mangaReaderMode = _mangaReaderMode,
    final this.introDuration = _introDuration,
    final this.seekDuration = _seekDuration,
    final this.volume = _volume,
    final this.autoNext = _autoNext,
    final this.autoPlay = _autoPlay,
    final this.doubleClickSwitchChapter = _doubleClickSwitchChapter,
    final this.animeAutoFullscreen = _animeAutoFullscreen,
    final this.mangaAutoFullscreen = _mangaAutoFullscreen,
  });

  @HiveField(1, defaultValue: _useSystemPreferredTheme)
  bool useSystemPreferredTheme;

  @HiveField(2, defaultValue: _useDarkMode)
  bool useDarkMode;

  @HiveField(3, defaultValue: _fullscreenVideoPlayer)
  bool fullscreenVideoPlayer;

  @HiveField(4, defaultValue: _locale)
  String? locale;

  @HiveField(5, defaultValue: _mangaReaderDirection)
  MangaDirections mangaReaderDirection;

  @HiveField(6, defaultValue: _mangaReaderSwipeDirection)
  MangaSwipeDirections mangaReaderSwipeDirection;

  @HiveField(7, defaultValue: _mangaReaderMode)
  MangaMode mangaReaderMode;

  @HiveField(8, defaultValue: _introDuration)
  int introDuration;

  @HiveField(9, defaultValue: _seekDuration)
  int seekDuration;

  @HiveField(10, defaultValue: _volume)
  int volume;

  @HiveField(11, defaultValue: _autoNext)
  bool autoNext;

  @HiveField(12, defaultValue: _autoPlay)
  bool autoPlay;

  @HiveField(13, defaultValue: _doubleClickSwitchChapter)
  bool doubleClickSwitchChapter;

  @HiveField(14, defaultValue: _animeAutoFullscreen)
  bool animeAutoFullscreen;

  @HiveField(15, defaultValue: _mangaAutoFullscreen)
  bool mangaAutoFullscreen;
}

@HiveType(typeId: TypeIds.mangaDirections)
enum MangaDirections {
  @HiveField(0)
  leftToRight,

  @HiveField(1)
  rightToLeft,
}

@HiveType(typeId: TypeIds.mangaSwipeDirections)
enum MangaSwipeDirections {
  @HiveField(0)
  horizontal,

  @HiveField(1)
  vertical,
}

@HiveType(typeId: TypeIds.mangaMode)
enum MangaMode {
  @HiveField(0)
  page,

  @HiveField(1)
  list,
}
