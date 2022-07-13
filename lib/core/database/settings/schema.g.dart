// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsSchema _$SettingsSchemaFromJson(Map<String, dynamic> json) =>
    SettingsSchema(
      locale: SettingsSchema._localeFromJson(json['locale'] as String),
      ignoreSSLCertificate: json['ignoreSSLCertificate'] as bool? ?? true,
    );

Map<String, dynamic> _$SettingsSchemaToJson(SettingsSchema instance) =>
    <String, dynamic>{
      'locale': SettingsSchema._localeToJson(instance.locale),
      'ignoreSSLCertificate': instance.ignoreSSLCertificate,
    };
