import 'package:extensions/extensions.dart' as extensions;

class PageArguments {
  PageArguments({
    required final this.type,
  });

  factory PageArguments.fromJson(final Map<String, String> json) {
    if (json['type'] == null) {
      throw ArgumentError("Got null value for 'type'");
    }

    return PageArguments(
      type: extensions.ExtensionType.values.firstWhere(
        (final extensions.ExtensionType type) => type.type == json['type'],
      ),
    );
  }

  extensions.ExtensionType type;

  Map<String, String> toJson() => <String, String>{
        'type': type.type,
      };
}
