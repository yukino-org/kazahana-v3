import 'package:json_annotation/json_annotation.dart';
import 'package:utilx/utilities/locale.dart';

part 'preferences.g.dart';

abstract class PreferencesSettingsSchemaDefaults {
  static const bool useSystemPreferredTheme = true;
  static const bool useDarkMode = false;
}

@JsonSerializable()
class PreferencesSettingsSchema {
  PreferencesSettingsSchema({
    final this.useSystemPreferredTheme =
        PreferencesSettingsSchemaDefaults.useSystemPreferredTheme,
    final this.useDarkMode = PreferencesSettingsSchemaDefaults.useDarkMode,
    final this.locale,
  });

  factory PreferencesSettingsSchema.fromJson(
    final Map<dynamic, dynamic> json,
  ) =>
      _$PreferencesSettingsSchemaFromJson(json.cast<String, dynamic>());

  int id = 0;

  bool useSystemPreferredTheme;
  bool useDarkMode;
  Locale? locale;

  Map<dynamic, dynamic> toJson() => _$PreferencesSettingsSchemaToJson(this);
}
