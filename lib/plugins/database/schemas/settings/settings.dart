import 'package:hive/hive.dart';

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
