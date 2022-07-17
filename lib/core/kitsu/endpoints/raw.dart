import 'dart:convert';
import '../../http.dart' as http;
import '../../utils/exports.dart';
import '../config.dart';

Future<List<T>> getBulkDataEndpoint<T>(
  final Uri url,
  final T Function(JsonMap) fromJson,
) async {
  final http.Response resp = await http.client.get(
    url,
    headers: KitsuConfig.defaultHeaders,
  );
  final JsonMap parsed = json.decode(utf8.decode(resp.bodyBytes)) as JsonMap;
  return castList<JsonMap>(parsed['data']).map(fromJson).toList();
}
