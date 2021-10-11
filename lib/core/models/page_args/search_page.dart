import 'package:collection/collection.dart';
import 'package:extensions/extensions.dart' as extensions;

class PageArguments {
  PageArguments({
    required final this.terms,
    required final this.autoSearch,
    required final this.pluginType,
  });

  factory PageArguments.fromJson(final Map<String, String> json) =>
      PageArguments(
        terms: json['terms'],
        autoSearch: json['autoSearch'] == 'true',
        pluginType: extensions.ExtensionType.values.firstWhereOrNull(
          (final extensions.ExtensionType x) => x.type == json['pluginType'],
        ),
      );

  String? terms;
  bool? autoSearch;
  extensions.ExtensionType? pluginType;

  Map<String, String> toJson() {
    final Map<String, String> json = <String, String>{};

    if (terms != null) {
      json['terms'] = terms!;
    }

    if (autoSearch != null) {
      json['autoSearch'] = autoSearch.toString();
    }

    if (pluginType != null) {
      json['pluginType'] = pluginType!.type;
    }

    return json;
  }
}
