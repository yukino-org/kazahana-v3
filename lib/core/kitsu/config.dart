abstract class KitsuConfig {
  static const String baseURL = 'https://kitsu.io/api/edge';
  static const Map<String, String> defaultHeaders = <String, String>{
    'Accept': 'application/vnd.api+json',
    'Content-Type': 'application/vnd.api+json',
  };

  static const int defaultPageLimit = 20;
  static const int defaultPageOffset = 0;

  static Uri findAnimeByIDURL(final String id) =>
      Uri.parse('$baseURL/anime?filter[id]=$id');

  static Uri searchAnimeURL(
    final String text, {
    final int limit = defaultPageLimit,
    final int offset = defaultPageOffset,
  }) =>
      Uri.parse(
        '$baseURL/anime?page[limit]=$limit&page[offset]=$offset&filter[text]=$text',
      );

  static Uri topOngoingAnimesURL({
    final int limit = defaultPageLimit,
    final int offset = defaultPageOffset,
  }) =>
      Uri.parse(
        '$baseURL/anime?page[limit]=$limit&page[offset]=$offset&filter[status]=current&sort=-user_count',
      );

  static Uri mostPopularAnimesURL({
    final int limit = defaultPageLimit,
    final int offset = defaultPageOffset,
  }) =>
      Uri.parse(
        '$baseURL/anime?page[limit]=$limit&page[offset]=$offset&sort=popularityRank',
      );

  static Uri findMangaByIDURL(final String id) =>
      Uri.parse('$baseURL/manga?filter[id]=$id');

  static Uri searchMangaURL(
    final String text, {
    final int limit = defaultPageLimit,
    final int offset = defaultPageOffset,
  }) =>
      Uri.parse(
        '$baseURL/manga?page[limit]=$limit&page[offset]=$offset&filter[text]=$text',
      );

  static Uri topOngoingMangasURL({
    final int limit = defaultPageLimit,
    final int offset = defaultPageOffset,
  }) =>
      Uri.parse(
        '$baseURL/manga?page[limit]=$limit&page[offset]=$offset&filter[status]=current&sort=-user_count',
      );

  static Uri mostPopularMangasURL({
    final int limit = defaultPageLimit,
    final int offset = defaultPageOffset,
  }) =>
      Uri.parse(
        '$baseURL/manga?page[limit]=$limit&page[offset]=$offset&sort=popularityRank',
      );
}
