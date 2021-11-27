import 'dart:convert';
import 'package:objectbox/objectbox.dart';
import './sub_schemas/keyboard_shortcuts/anime.dart';
import './sub_schemas/keyboard_shortcuts/manga.dart';
import '../../../video_player/video_player.dart';

export './sub_schemas/keyboard_shortcuts/anime.dart';
export './sub_schemas/keyboard_shortcuts/manga.dart';

const bool _useSystemPreferredTheme = true;
const bool _useDarkMode = false;
const String? _locale = null;
const MangaDirections _mangaReaderDirection = MangaDirections.leftToRight;
const MangaSwipeDirections _mangaReaderSwipeDirection =
    MangaSwipeDirections.horizontal;
const MangaMode _mangaReaderMode = MangaMode.page;
const int _introDuration = VideoPlayer.defaultIntroLength;
const int _seekDuration = VideoPlayer.defaultSeekLength;
const bool _autoNext = false;
const bool _autoPlay = false;
const bool _doubleClickSwitchChapter = true;
const bool _animeAutoFullscreen = true;
const bool _mangaAutoFullscreen = true;
const int _animeTrackerWatchPercent = 80;
const bool _animeForceLandscape = true;
const bool _disableAnimations = false;
const bool _ignoreBadHttpCertificate = false;

@Entity()
class SettingsSchema {
  SettingsSchema({
    final this.useSystemPreferredTheme = _useSystemPreferredTheme,
    final this.useDarkMode = _useDarkMode,
    final this.locale = _locale,
    final this.mangaReaderDirection = _mangaReaderDirection,
    final this.mangaReaderSwipeDirection = _mangaReaderSwipeDirection,
    final this.mangaReaderMode = _mangaReaderMode,
    final this.introDuration = _introDuration,
    final this.seekDuration = _seekDuration,
    final this.autoNext = _autoNext,
    final this.autoPlay = _autoPlay,
    final this.doubleClickSwitchChapter = _doubleClickSwitchChapter,
    final this.animeAutoFullscreen = _animeAutoFullscreen,
    final this.mangaAutoFullscreen = _mangaAutoFullscreen,
    final this.animeTrackerWatchPercent = _animeTrackerWatchPercent,
    final this.animeForceLandscape = _animeForceLandscape,
    final this.disableAnimations = _disableAnimations,
    final this.animeShortcuts_,
    final this.ignoreBadHttpCertificate = _ignoreBadHttpCertificate,
    final this.mangaShortcuts_,
  });

  int id = 0;
  bool useSystemPreferredTheme;
  bool useDarkMode;
  String? locale;
  int introDuration;
  int seekDuration;
  bool autoNext;
  bool autoPlay;
  bool doubleClickSwitchChapter;
  bool animeAutoFullscreen;
  bool mangaAutoFullscreen;
  int animeTrackerWatchPercent;
  bool animeForceLandscape;
  bool disableAnimations;
  bool ignoreBadHttpCertificate;

  MangaDirections mangaReaderDirection;
  String get mangaReaderDirection_ => mangaReaderDirection.name;
  set mangaReaderDirection_(final String val) {
    mangaReaderDirection = MangaDirections.values
        .firstWhere((final MangaDirections x) => x.name == val);
  }

  MangaSwipeDirections mangaReaderSwipeDirection;
  String get mangaReaderSwipeDirection_ => mangaReaderSwipeDirection.name;
  set mangaReaderSwipeDirection_(final String val) {
    mangaReaderSwipeDirection = MangaSwipeDirections.values
        .firstWhere((final MangaSwipeDirections x) => x.name == val);
  }

  MangaMode mangaReaderMode;
  String get mangaReaderMode_ => mangaReaderMode.name;
  set mangaReaderMode_(final String val) {
    mangaReaderMode =
        MangaMode.values.firstWhere((final MangaMode x) => x.name == val);
  }

  String? animeShortcuts_;
  AnimeKeyboardShortcuts get animeShortcuts => animeShortcuts_ != null
      ? AnimeKeyboardShortcuts.fromJson(
          json.decode(animeShortcuts_!) as Map<dynamic, dynamic>,
        )
      : AnimeKeyboardShortcuts.fromPartial();
  set animeShortcuts(final AnimeKeyboardShortcuts shortcuts) =>
      animeShortcuts_ = json.encode(shortcuts.toJson());

  String? mangaShortcuts_;
  MangaKeyboardShortcuts get mangaShortcuts => mangaShortcuts_ != null
      ? MangaKeyboardShortcuts.fromJson(
          json.decode(mangaShortcuts_!) as Map<dynamic, dynamic>,
        )
      : MangaKeyboardShortcuts.fromPartial();
  set mangaShortcuts(final MangaKeyboardShortcuts shortcuts) =>
      mangaShortcuts_ = json.encode(shortcuts.toJson());
}

enum MangaDirections {
  leftToRight,
  rightToLeft,
}

enum MangaSwipeDirections {
  horizontal,
  vertical,
}

enum MangaMode {
  page,
  list,
}
