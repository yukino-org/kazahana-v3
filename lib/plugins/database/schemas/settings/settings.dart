import 'package:hive/hive.dart';
import '../../../../core/models/player.dart';

part 'settings.g.dart';

const _useSystemPreferredTheme = true;
const _useDarkMode = false;
const _fullscreenVideoPlayer = false;
const _locale = null;
const _mangaReaderDirection = MangaDirections.leftToRight;
const _mangaReaderSwipeDirection = MangaSwipeDirections.horizontal;
const _mangaReaderMode = MangaMode.page;
const _introDuration = Player.defaultIntroLength;
const _seekDuration = Player.defaultSeekLength;
const _volume = Player.maxVolume;
const _autoNext = false;
const _autoPlay = false;
const _doubleClickSwitchChapter = true;

@HiveType(typeId: 1)
class SettingsSchema extends HiveObject {
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

  SettingsSchema({
    this.useSystemPreferredTheme = _useSystemPreferredTheme,
    this.useDarkMode = _useDarkMode,
    this.fullscreenVideoPlayer = _fullscreenVideoPlayer,
    this.locale = _locale,
    this.mangaReaderDirection = _mangaReaderDirection,
    this.mangaReaderSwipeDirection = _mangaReaderSwipeDirection,
    this.mangaReaderMode = _mangaReaderMode,
    this.introDuration = _introDuration,
    this.seekDuration = _seekDuration,
    this.volume = _volume,
    this.autoNext = _autoNext,
    this.autoPlay = _autoPlay,
    this.doubleClickSwitchChapter = _doubleClickSwitchChapter,
  });
}

@HiveType(typeId: 2)
enum MangaDirections {
  @HiveField(0)
  leftToRight,

  @HiveField(1)
  rightToLeft,
}

@HiveType(typeId: 3)
enum MangaSwipeDirections {
  @HiveField(0)
  horizontal,

  @HiveField(1)
  vertical,
}

@HiveType(typeId: 4)
enum MangaMode {
  @HiveField(0)
  page,

  @HiveField(1)
  list,
}
