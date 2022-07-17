import '../config.dart';
import '../models/exports.dart';
import 'raw.dart';

abstract class KitsuMangaEndpoints {
  static Future<KitsuManga> getByID(final String id) async =>
      (await getBulkDataEndpoint(
        KitsuConfig.findMangaByIDURL(id),
        KitsuManga.fromJson,
      ))[0];

  static Future<List<KitsuManga>> search(final String terms) async =>
      getBulkDataEndpoint(
        KitsuConfig.searchMangaURL(terms),
        KitsuManga.fromJson,
      );

  static Future<List<KitsuManga>> topOngoingMangas() async =>
      getBulkDataEndpoint(
        KitsuConfig.topOngoingMangasURL(),
        KitsuManga.fromJson,
      );

  static Future<List<KitsuManga>> mostPopularMangas() async =>
      getBulkDataEndpoint(
        KitsuConfig.mostPopularMangasURL(),
        KitsuManga.fromJson,
      );
}
