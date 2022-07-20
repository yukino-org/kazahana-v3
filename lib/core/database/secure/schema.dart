import 'package:json_annotation/json_annotation.dart';
import '../../exports.dart';

part 'schema.g.dart';

@JsonSerializable()
class SecureSchema {
  SecureSchema({
    this.anilistToken,
  });

  factory SecureSchema.fromJson(final JsonMap json) =>
      _$SecureSchemaFromJson(json.cast<String, dynamic>());

  @JsonKey(fromJson: _anilistTokenFromJson, toJson: _anilistTokenToJson)
  AnilistToken? anilistToken;

  JsonMap toJson() => _$SecureSchemaToJson(this);

  static AnilistToken? _anilistTokenFromJson(final dynamic value) =>
      value is JsonMap ? AnilistToken(value.cast<String, String>()) : null;
  static JsonMap? _anilistTokenToJson(final AnilistToken? value) => value?.json;
}
