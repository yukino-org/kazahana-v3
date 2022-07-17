import 'dart:convert';
import '../../exports.dart';
import '../../http.dart' as http;

enum KitsuSeasonTrendsKind {
  laplace,
  rated,
  upvotes,
  users,
  wilson,
}

class KitsuSeasonTrendsData {
  const KitsuSeasonTrendsData({
    required this.season,
    required this.year,
    required this.data,
  });

  factory KitsuSeasonTrendsData.fromJson(final JsonMap json) =>
      KitsuSeasonTrendsData(
        season: parseAnimeSeason(json['season'] as String),
        year: json['year'] as int,
        data: castList<JsonMap>(json['data']).map(KitsuAnime.fromJson).toList(),
      );

  final AnimeSeasons season;
  final int year;
  final List<KitsuAnime> data;
}

abstract class KitsuSeasonTrends {
  static const String baseEndpointURL =
      'https://cdn.jsdelivr.net/gh/yukino-org/seasonal-trends@data';

  static Future<KitsuSeasonTrendsData>
      getTrendingAnimesBasedOnUpvotes() async =>
          getEndpointData(getEndpointURL(KitsuSeasonTrendsKind.upvotes));

  static Future<KitsuSeasonTrendsData> getEndpointData(final Uri url) async {
    final http.Response resp = await http.client.get(url);
    final JsonMap parsed = json.decode(resp.body) as JsonMap;
    return KitsuSeasonTrendsData.fromJson(parsed);
  }

  static Uri getEndpointURL(final KitsuSeasonTrendsKind kind) =>
      Uri.parse('$baseEndpointURL/data-${kind.name}.json');
}
