import '../../trackers/myanimelist/myanimelist.dart';

class PageArguments {
  PageArguments({
    required final this.type,
  });

  factory PageArguments.fromJson(final Map<String, String> json) {
    if (json['type'] == null) {
      throw ArgumentError("Got null value for 'type'");
    }

    return PageArguments(
      type: ListType.values.firstWhere(
        (final ListType type) => type.type == json['type'],
      ),
    );
  }

  ListType type;

  Map<String, String> toJson() => <String, String>{
        'type': type.type,
      };
}
