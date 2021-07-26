class PageArguments {
  String src;
  String plugin;

  PageArguments({required this.src, required this.plugin});

  static PageArguments fromJson(Map<String, String> json) {
    if (json['src'] == null) throw ('Got null value for \'src\'');
    if (json['plugin'] == null) throw ('Got null value for \'plugin\'');

    return PageArguments(src: json['src']!, plugin: json['plugin']!);
  }

  Map<String, String> toJson() => {
        'src': src,
        'plugin': plugin,
      };
}
