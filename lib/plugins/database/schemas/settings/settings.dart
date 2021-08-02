import 'package:hive/hive.dart';
import '../../../../core/models/player.dart' show Player;

part 'settings.g.dart';

@HiveType(typeId: 1)
class SettingsSchema extends HiveObject {
  @HiveField(1, defaultValue: true)
  late bool useSystemPreferredTheme;

  @HiveField(2, defaultValue: false)
  late bool useDarkMode;

  @HiveField(3, defaultValue: false)
  late bool fullscreenVideoPlayer;

  @HiveField(4)
  late String? locale;

  @HiveField(5, defaultValue: MangaDirections.leftToRight)
  late MangaDirections mangaReaderDirection;

  @HiveField(6, defaultValue: MangaSwipeDirections.horizontal)
  late MangaSwipeDirections mangaReaderSwipeDirection;

  @HiveField(7, defaultValue: MangaMode.page)
  late MangaMode mangaReaderMode;

  @HiveField(8, defaultValue: Player.defaultIntroLength)
  late int introDuration;

  @HiveField(9, defaultValue: Player.defaultSeekLength)
  late int seekDuration;

  @HiveField(10, defaultValue: Player.maxVolume)
  late int volume;

  @HiveField(11, defaultValue: false)
  late bool autoNext;

  @HiveField(12, defaultValue: false)
  late bool autoPlay;
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
