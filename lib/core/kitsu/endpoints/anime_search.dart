import 'dart:convert';
import '../../http.dart' as http;
import '../../utils/exports.dart';
import '../config.dart';
import '../models/exports.dart';

abstract class KitsuAnimeSearchEndpoint {
  static Future<List<KitsuAnime>> search(final String terms) async {
    final http.Response resp = await http.client.get(
      KitsuConfig.searchAnimeURL(terms),
      headers: KitsuConfig.defaultHeaders,
    );
    final JsonMap parsed = json.decode(utf8.decode(resp.bodyBytes)) as JsonMap;
    return castList<JsonMap>(parsed['data']).map(KitsuAnime.fromJson).toList();
  }
}
