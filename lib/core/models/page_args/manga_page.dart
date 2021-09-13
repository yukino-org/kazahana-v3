class PageArguments {
  PageArguments({
    required final this.src,
    required final this.plugin,
  });

  factory PageArguments.fromJson(final Map<String, String> json) {
    if (json['src'] == null) {
      throw ArgumentError("Got null value for 'src'");
    }
    if (json['plugin'] == null) {
      throw ArgumentError("Got null value for 'plugin'");
    }

    return PageArguments(src: json['src']!, plugin: json['plugin']!);
  }

  String src;
  String plugin;

  Map<String, String> toJson() => <String, String>{
        'src': src,
        'plugin': plugin,
      };
}
