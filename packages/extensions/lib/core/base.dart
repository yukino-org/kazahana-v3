import 'package:utilx/utilities/locale.dart';
import './version.dart';

enum ExtensionType {
  anime,
  manga,
}

extension ExtensionTypeUtils on ExtensionType {
  String get type => toString().split('.').last;
}

class BaseExtension {
  BaseExtension({
    required final this.name,
    required final this.id,
    required final this.author,
    required final this.version,
    required final this.type,
    required final this.image,
    required final this.nsfw,
    required final this.defaultLocale,
  });

  factory BaseExtension.fromJson(final Map<dynamic, dynamic> json) =>
      BaseExtension(
        name: json['name'] as String,
        id: json['id'] as String,
        author: json['author'] as String,
        version: ExtensionVersion.parse(json['version'] as String),
        type: ExtensionType.values.firstWhere(
          (final ExtensionType type) => type.type == (json['type'] as String),
        ),
        image: json['image'] as String,
        nsfw: json['nsfw'] as bool,
        defaultLocale: Locale.parse(json['defaultLocale'] as String),
      );

  final String name;
  final String id;
  final String author;
  final ExtensionVersion version;
  final ExtensionType type;
  final String image;
  final bool nsfw;
  final Locale defaultLocale;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'name': name,
        'id': id,
        'author': author,
        'version': version.toString(),
        'type': type.type,
        'image': image,
        'nsfw': nsfw,
        'defaultLocale': defaultLocale.toCodeString(),
      };
}
