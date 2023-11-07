// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsSchema _$SettingsSchemaFromJson(Map<String, dynamic> json) =>
    SettingsSchema(
      locale: SettingsSchema._localeFromJson(json['locale'] as String?),
      ignoreSSLCertificate: json['ignoreSSLCertificate'] as bool? ?? true,
      darkMode: json['darkMode'] as bool? ?? true,
      primaryColor: json['primaryColor'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      disableAnimations: json['disableAnimations'] as bool? ?? false,
      useSystemPreferredTheme:
          json['useSystemPreferredTheme'] as bool? ?? false,
      scaleMultiplier: (json['scaleMultiplier'] as num?)?.toDouble() ??
          RelativeScaleData.defaultScaleMultiplier,
    );

Map<String, dynamic> _$SettingsSchemaToJson(SettingsSchema instance) =>
    <String, dynamic>{
      'locale': SettingsSchema._localeToJson(instance.locale),
      'ignoreSSLCertificate': instance.ignoreSSLCertificate,
      'darkMode': instance.darkMode,
      'primaryColor': instance.primaryColor,
      'backgroundColor': instance.backgroundColor,
      'disableAnimations': instance.disableAnimations,
      'useSystemPreferredTheme': instance.useSystemPreferredTheme,
      'scaleMultiplier': instance.scaleMultiplier,
    };
