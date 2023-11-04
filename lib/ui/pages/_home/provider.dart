import 'package:kazahana/core/exports.dart';

class UnderScoreHomePageProvider extends StatedChangeNotifier {
  TenkaType type = TenkaType.anime;

  final StatedValue<List<AnilistMedia>> trendingAnime =
      StatedValue<List<AnilistMedia>>();
  final StatedValue<List<AnilistMedia>> topOngoingAnime =
      StatedValue<List<AnilistMedia>>();
  final StatedValue<List<AnilistMedia>> mostPopularAnime =
      StatedValue<List<AnilistMedia>>();

  final StatedValue<List<AnilistMedia>> trendingManga =
      StatedValue<List<AnilistMedia>>();
  final StatedValue<List<AnilistMedia>> topOngoingManga =
      StatedValue<List<AnilistMedia>>();
  final StatedValue<List<AnilistMedia>> mostPopularManga =
      StatedValue<List<AnilistMedia>>();

  Future<void> initialize() async {
    final TenkaType? lastVisitedType = await getHomeLastVisited();
    if (lastVisitedType != null && type != lastVisitedType) {
      type = lastVisitedType;
      notifyListeners();
    }

    fetch(type);
  }

  Future<void> setType(final TenkaType type) async {
    this.type = type;
    fetch(type);
    notifyListeners();
    await setHomeLastVisited(type);
  }

  void fetch(final TenkaType type) {
    switch (type) {
      case TenkaType.anime:
        fetchTrendingAnimes();
        fetchTopOngoingAnimes();
        fetchMostPopularAnimes();

      case TenkaType.manga:
        fetchTrendingMangas();
        fetchTopOngoingMangas();
        fetchMostPopularMangas();
    }
  }

  Future<void> fetchTrendingAnimes() async {
    if (!trendingAnime.isWaiting) return;

    try {
      trendingAnime.finish(await AnilistMediaEndpoints.trendingAnimes());
    } catch (error, stackTrace) {
      trendingAnime.fail(error, stackTrace);
    }
    if (!mounted) return;
    notifyListeners();
  }

  Future<void> fetchTopOngoingAnimes() async {
    if (!topOngoingAnime.isWaiting) return;

    try {
      topOngoingAnime.finish(await AnilistMediaEndpoints.topOngoingAnimes());
    } catch (error, stackTrace) {
      topOngoingAnime.fail(error, stackTrace);
    }
    if (!mounted) return;
    notifyListeners();
  }

  Future<void> fetchMostPopularAnimes() async {
    if (!mostPopularAnime.isWaiting) return;

    try {
      mostPopularAnime.finish(await AnilistMediaEndpoints.mostPopularAnimes());
    } catch (error, stackTrace) {
      mostPopularAnime.fail(error, stackTrace);
    }
    if (!mounted) return;
    notifyListeners();
  }

  Future<void> fetchTrendingMangas() async {
    if (!trendingManga.isWaiting) return;

    try {
      trendingManga.finish(await AnilistMediaEndpoints.trendingMangas());
    } catch (error, stackTrace) {
      trendingManga.fail(error, stackTrace);
    }
    if (!mounted) return;
    notifyListeners();
  }

  Future<void> fetchTopOngoingMangas() async {
    if (!topOngoingManga.isWaiting) return;

    try {
      topOngoingManga.finish(await AnilistMediaEndpoints.topOngoingMangas());
    } catch (error, stackTrace) {
      topOngoingManga.fail(error, stackTrace);
    }
    if (!mounted) return;
    notifyListeners();
  }

  Future<void> fetchMostPopularMangas() async {
    if (!mostPopularManga.isWaiting) return;

    try {
      mostPopularManga.finish(await AnilistMediaEndpoints.mostPopularMangas());
    } catch (error, stackTrace) {
      mostPopularManga.fail(error, stackTrace);
    }
    if (!mounted) return;
    notifyListeners();
  }

  static const String kHomeLastVisitedKey = 'home_last_visited';

  static Future<TenkaType?> getHomeLastVisited() async {
    final String? value = await CacheDatabase.get<String?>(kHomeLastVisitedKey);
    return value != null ? EnumUtils.find(TenkaType.values, value) : null;
  }

  static Future<void> setHomeLastVisited(final TenkaType type) async {
    await CacheDatabase.set(kHomeLastVisitedKey, type.name);
  }
}
