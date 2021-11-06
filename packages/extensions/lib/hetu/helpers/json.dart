import 'dart:convert';

const String jsonDefinitions = '''
external fun jsonEncode(data) -> str;
external fun jsonDecode(data: str); // -> dynamic
''';

String jsonEncode(final dynamic data) => json.encode(data);

dynamic jsonDecode(final String data) => json.decode(data);
