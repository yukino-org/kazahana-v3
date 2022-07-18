import 'package:json_annotation/json_annotation.dart';
import '../../utils/exports.dart';

part 'schema.g.dart';

@JsonSerializable()
class SettingsSchema {
  SettingsSchema({
    this.locale,
    this.ignoreSSLCertificate = true,
  });

  factory SettingsSchema.fromJson(final JsonMap json) =>
      _$SettingsSchemaFromJson(json.cast<String, dynamic>());

  @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson)
  Locale? locale;
  bool ignoreSSLCertificate;

  JsonMap toJson() => _$SettingsSchemaToJson(this);

  static Locale _localeFromJson(final String value) => Locale.parse(value);
  static String? _localeToJson(final Locale? value) => value?.toCodeString();
}
