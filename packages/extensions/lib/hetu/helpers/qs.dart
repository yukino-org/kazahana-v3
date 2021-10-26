const String qsDefinitions = '''
external fun qsEncode(data: Map<str>) -> str;
external fun qsDecode(data: str) -> Map<str>;
''';

String qsEncode(final Map<dynamic, dynamic> map) =>
    Uri(queryParameters: map.cast<String, String>()).query;

Map<String, String> qsDecode(final String map) => Uri.splitQueryString(map);
