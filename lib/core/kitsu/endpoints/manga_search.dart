import 'dart:convert';
import '../../http.dart' as http;
import '../../utils/exports.dart';
import '../config.dart';
import '../models/exports.dart';

abstract class KitsuMangaSearchEndpoint {
  static Future<List<KitsuManga>> search(final String terms) async {
    final http.Response resp = await http.client.get(
      KitsuConfig.searchMangaURL(terms),
      headers: KitsuConfig.defaultHeaders,
    );
    final JsonMap parsed = json.decode(resp.body) as JsonMap;
    return castList<JsonMap>(parsed['data']).map(KitsuManga.fromJson).toList();
  }
}
