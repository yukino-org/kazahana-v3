import 'package:json_annotation/json_annotation.dart';
import 'package:kazahana/ui/utils/relative_scale.dart';
import '../../utils/exports.dart';

part 'schema.g.dart';

@JsonSerializable()
class SettingsSchema {
  SettingsSchema({
    this.locale,
    this.ignoreSSLCertificate = true,
    this.darkMode = true,
    this.primaryColor,
    this.backgroundColor,
    this.disableAnimations = false,
    this.useSystemPreferredTheme = false,
    this.scaleMultiplier = RelativeScaleData.defaultMultiplier,
  });

  factory SettingsSchema.fromJson(final JsonMap json) =>
      _$SettingsSchemaFromJson(json.cast<String, dynamic>());

  @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson)
  Locale? locale;
  bool ignoreSSLCertificate;
  bool darkMode;
  String? primaryColor;
  String? backgroundColor;
  bool disableAnimations;
  bool useSystemPreferredTheme;
  double scaleMultiplier;

  JsonMap toJson() => _$SettingsSchemaToJson(this);

  static Locale? _localeFromJson(final String? value) =>
      value != null ? Locale.parse(value) : null;
  static String? _localeToJson(final Locale? value) => value?.code;
}
