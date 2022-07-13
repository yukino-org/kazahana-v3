import 'package:json_annotation/json_annotation.dart';
import 'package:utilx/locale.dart';

part 'schema.g.dart';

@JsonSerializable()
class SettingsSchema {
  SettingsSchema({
    this.locale,
    this.ignoreSSLCertificate = true,
  });

  factory SettingsSchema.fromJson(final Map<dynamic, dynamic> json) =>
      _$SettingsSchemaFromJson(json.cast<String, dynamic>());

  @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson)
  Locale? locale;
  bool ignoreSSLCertificate;

  Map<dynamic, dynamic> toJson() => _$SettingsSchemaToJson(this);

  static Locale _localeFromJson(final String value) => Locale.parse(value);
  static String? _localeToJson(final Locale? value) => value?.toCodeString();
}
