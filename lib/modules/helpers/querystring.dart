class QueryString {
  QueryString(this.query) {
    _parse();
  }

  factory QueryString.fromJson(final Map<String, dynamic> json) =>
      QueryString(QueryString.stringify(json));

  final String query;
  late final Map<String, String> parsed;

  void _parse() {
    parsed = Uri.splitQueryString(query);
  }

  String get(final String key) => parsed[key]!;

  @override
  String toString() => QueryString.stringify(parsed);

  static String stringify(final Map<String, dynamic> query) =>
      Uri(queryParameters: query).query;
}
