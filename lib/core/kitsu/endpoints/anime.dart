import '../config.dart';
import '../models/exports.dart';
import 'raw.dart';

abstract class KitsuAnimeEndpoints {
  static Future<KitsuAnime> getByID(final String id) async =>
      (await getBulkDataEndpoint(
        KitsuConfig.findAnimeByIDURL(id),
        KitsuAnime.fromJson,
      ))[0];

  static Future<List<KitsuAnime>> search(final String terms) async =>
      getBulkDataEndpoint(
        KitsuConfig.searchAnimeURL(terms),
        KitsuAnime.fromJson,
      );

  static Future<List<KitsuAnime>> topOngoingAnimes() async =>
      getBulkDataEndpoint(
        KitsuConfig.topOngoingAnimesURL(),
        KitsuAnime.fromJson,
      );

  static Future<List<KitsuAnime>> mostPopularAnimes() async =>
      getBulkDataEndpoint(
        KitsuConfig.mostPopularAnimesURL(),
        KitsuAnime.fromJson,
      );
}
