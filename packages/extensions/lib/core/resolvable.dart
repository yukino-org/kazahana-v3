import 'package:http/http.dart' as http;
import 'package:utilx/utilities/locale.dart';
import './base.dart';
import './resolved.dart';
import './version.dart';

class ResolvableExtension extends BaseExtension {
  ResolvableExtension({
    required final String name,
    required final String id,
    required final String author,
    required final ExtensionVersion version,
    required final ExtensionType type,
    required final String image,
    required final bool nsfw,
    required final Locale defaultLocale,
    required final this.source,
  }) : super(
          name: name,
          id: id,
          author: author,
          version: version,
          type: type,
          image: image,
          nsfw: nsfw,
          defaultLocale: defaultLocale,
        );

  factory ResolvableExtension.fromJson(final Map<dynamic, dynamic> json) {
    final BaseExtension base = BaseExtension.fromJson(json);

    return ResolvableExtension(
      name: base.name,
      id: base.id,
      author: base.author,
      version: base.version,
      type: base.type,
      image: base.image,
      source: json['source'] as String,
      nsfw: base.nsfw,
      defaultLocale: base.defaultLocale,
    );
  }

  final String source;

  Future<ResolvedExtension> resolve() async {
    final http.Response res = await http.get(Uri.parse(source));

    return ResolvedExtension(
      name: name,
      id: id,
      author: author,
      version: version,
      type: type,
      image: image,
      code: res.body,
      nsfw: nsfw,
      defaultLocale: defaultLocale,
    );
  }

  @override
  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        ...super.toJson(),
        'source': source,
      };
}
