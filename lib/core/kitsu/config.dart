abstract class KitsuConfig {
  static const String baseURL = 'https://kitsu.io/api/edge';
  static const Map<String, String> defaultHeaders = <String, String>{
    'Accept': 'application/vnd.api+json',
    'Content-Type': 'application/vnd.api+json',
  };

  static Uri searchAnimeURL(final String text) =>
      Uri.parse('$baseURL/anime?filter[text]=$text');

  static Uri searchMangaURL(final String text) =>
      Uri.parse('$baseURL/manga?filter[text]=$text');
}
