import 'package:collection/collection.dart';

class QueryString {
  QueryString(this.query) {
    _parse();
  }

  factory QueryString.fromJson(final Map<String, dynamic> json) =>
      QueryString(QueryString.stringify(json));

  void _parse() {
    query.split('&').forEach((final String x) {
      final List<String> split = x.split('=');
      final String k = Uri.decodeQueryComponent(split[0]);
      final String v = Uri.decodeQueryComponent(split[1]);
      parsed[k] ??= <String>[];
      parsed[k]!.add(v);
    });
  }

  final String query;
  late final Map<String, List<String>> _parsed = <String, List<String>>{};

  Map<String, List<String>> get parsed => _parsed;

  String get(final String key) => _parsed[key]!.first;

  String? getOrNull(final String key) => _parsed[key]?.firstOrNull;

  List<String> getAll(final String key) => _parsed[key] ?? <String>[];

  @override
  String toString() => QueryString.stringify(_parsed);

  static String stringify(final Map<String, dynamic> query) =>
      Uri(queryParameters: query).query;
}
