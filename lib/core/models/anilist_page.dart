import '../trackers/anilist/anilist.dart';

class PageArguments {
  PageArguments({
    required final this.type,
  });

  factory PageArguments.fromJson(final Map<String, String> json) {
    if (json['type'] == null) {
      throw ArgumentError("Got null value for 'type'");
    }

    return PageArguments(
      type: MediaType.values.firstWhere(
        (final MediaType type) => type.type == json['type'],
      ),
    );
  }

  MediaType type;

  Map<String, String> toJson() => <String, String>{
        'type': type.type,
      };
}
