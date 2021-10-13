import 'dart:convert';

String jsonEncode(final dynamic data) => json.encode(data);

dynamic jsonDecode(final String data) => json.decode(data);
