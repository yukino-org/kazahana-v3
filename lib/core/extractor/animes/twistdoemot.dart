import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fuzzy/fuzzy.dart';
import 'package:encrypt/encrypt.dart' as crypto;
import 'model.dart';

const twistDecryptKey = "267041df55ca2b36f2e322d05ee2c9cf";

class TwistSearchInfo extends SearchInfo {
  final String? altTitle;

  TwistSearchInfo(String url, String title, {String? thumbnail, this.altTitle})
      : super(url, title, thumbnail: thumbnail);
}

class TwistEpisodeSource {
  final int episode;
  final String source;
  EpisodeSource? cachedSource;

  TwistEpisodeSource(this.episode, this.source);

  EpisodeSource getSource() {
    if (cachedSource == null) {
      final key = crypto.Key.fromUtf8(twistDecryptKey);
      final algorithm =
          crypto.Encrypter(crypto.AES(key, mode: crypto.AESMode.cbc));
      final decrypted = algorithm.decrypt(crypto.Encrypted.fromBase64(source));
      cachedSource = EpisodeSource(decrypted, "unknown");
    }

    return cachedSource!;
  }
}

class TwistMoe implements AnimeExtractor {
  final baseURL = "https://twist.moe";
  final apiURL = "https://api.twist.moe/api";
  Fuzzy<TwistSearchInfo>? searcher;
  final Map<String, List<TwistEpisodeSource>> animeSourceCache = {};

  String searchApiURL() => "$apiURL/anime";
  String animeURL(String slug) => '$baseURL/a/$slug';
  String animeApiURL(String slug) => '$apiURL/anime/$slug';
  String animeSourcesURL(String slug) => '${animeApiURL(slug)}/sources';

  String? extractSlugFromURL(String url) =>
      RegExp(r"https:\/\/twist\.moe\/a\/([\d\w-_]+)\/?").stringMatch(url);

  @override
  Future<List<SearchInfo>> search(final String terms) async {
    if (searcher == null) {
      try {
        final res = await http.get(Uri.parse(Uri.encodeFull(searchApiURL())));
        final animes = (json.decode(res.body) as List<dynamic>)
            .map((x) => TwistSearchInfo(animeURL(x.slug.slug), x.title))
            .toList();
        searcher = Fuzzy<TwistSearchInfo>(animes,
            options: FuzzyOptions(shouldSort: true, keys: [
              WeightedKey(name: "title", getter: (x) => x.title, weight: 2),
              WeightedKey(
                  name: "altTitle", getter: (x) => x.altTitle ?? "", weight: 1),
            ]));
      } catch (e) {
        return [];
      }
    }

    return searcher!.search(terms).map((x) => x.item).toList();
  }

  @override
  Future<AnimeInfo> getInfo(Uri url) async {
    final slug = extractSlugFromURL(url.toString());
    if (slug == null) throw ("Failed to parse slug from URL");

    try {
      final res = await http.get(Uri.parse(Uri.encodeFull(animeApiURL(slug))));

      final parsed = json.decode(res.body);

      final animeURLP = animeURL(slug);
      final episodes = (parsed.episodes as List<dynamic>)
          .map(
              (x) => EpisodeInfo(x.number.toString(), '$animeURLP/${x.number}'))
          .toList();
      return AnimeInfo(animeURLP, parsed.title, episodes);
    } catch (e) {
      throw ("Failed to fetch anime information: ${e.toString()}");
    }
  }

  @override
  Future<List<EpisodeSource>> getSources(Uri url) async {
    final slug = extractSlugFromURL(url.toString());
    if (slug == null) throw ("Failed to parse slug from URL");

    final episode =
        int.tryParse(RegExp(r"/(\d+)$/").stringMatch(url.toString()) ?? "1");
    if (episode == null) throw ("Failed to parse episode from URL");

    if (animeSourceCache[slug] == null) {
      try {
        final res =
            await http.get(Uri.parse(Uri.encodeFull(animeSourcesURL(slug))));

        animeSourceCache[slug] = json
            .decode(res.body)
            .map((x) => TwistEpisodeSource(x.number, x.source));
      } catch (e) {
        throw ("Failed to fetch episode sources: ${e.toString()}");
      }
    }

    final source =
        animeSourceCache[slug]?.firstWhere((x) => x.episode == episode);
    if (source == null) throw ("Failed to find source for the episode");

    return [source.getSource()];
  }
}
