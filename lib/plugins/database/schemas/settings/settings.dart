import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 1)
class SettingsSchema extends HiveObject {
  @HiveField(0)
  bool fullscreenVideoPlayer;

  SettingsSchema({required this.fullscreenVideoPlayer});
}

final defaultSettings = SettingsSchema(
  fullscreenVideoPlayer: true,
);
