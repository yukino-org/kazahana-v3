String qsEncode(final Map<dynamic, dynamic> map) =>
    Uri(queryParameters: map.cast<String, String>()).query;

Map<String, String> qsDecode(final String map) => Uri.splitQueryString(map);
