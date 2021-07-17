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
}
