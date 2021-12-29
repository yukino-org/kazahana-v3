import 'package:json_annotation/json_annotation.dart';

part 'developers.g.dart';

abstract class DevelopersSettingsSchemaDefaults {
  static const bool useSystemPreferredTheme = true;
  static const bool useDarkMode = false;
  static const bool disableAnimations = false;
  static const bool ignoreBadHttpCertificate = false;
}

@JsonSerializable()
class DevelopersSettingsSchema {
  DevelopersSettingsSchema({
    final this.ignoreBadHttpCertificate =
        DevelopersSettingsSchemaDefaults.ignoreBadHttpCertificate,
    final this.disableAnimations =
        DevelopersSettingsSchemaDefaults.disableAnimations,
  });

  factory DevelopersSettingsSchema.fromJson(
    final Map<dynamic, dynamic> json,
  ) =>
      _$DevelopersSettingsSchemaFromJson(json.cast<String, dynamic>());

  int id = 0;

  bool ignoreBadHttpCertificate;
  bool disableAnimations;

  Map<dynamic, dynamic> toJson() => _$DevelopersSettingsSchemaToJson(this);
}
