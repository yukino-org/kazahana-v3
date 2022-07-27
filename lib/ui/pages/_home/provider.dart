import '../../../core/exports.dart';

class UnderScoreHomePageProvider extends StatedChangeNotifier {
  TenkaType type = TenkaType.anime;

  final StatedValue<List<AnilistMedia>> trendingAnimes =
      StatedValue<List<AnilistMedia>>();
  final StatedValue<List<AnilistMedia>> topOngoingAnimes =
      StatedValue<List<AnilistMedia>>();
  final StatedValue<List<AnilistMedia>> mostPopularAnimes =
      StatedValue<List<AnilistMedia>>();

  final StatedValue<List<AnilistMedia>> trendingMangas =
      StatedValue<List<AnilistMedia>>();
  final StatedValue<List<AnilistMedia>> topOngoingMangas =
      StatedValue<List<AnilistMedia>>();
  final StatedValue<List<AnilistMedia>> mostPopularMangas =
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
        break;

      case TenkaType.manga:
        fetchTrendingMangas();
        fetchTopOngoingMangas();
        fetchMostPopularMangas();
        break;
    }
  }

  Future<void> fetchTrendingAnimes() async {
    if (!trendingAnimes.isWaiting) return;

    try {
      trendingAnimes.finish(await AnilistMediaEndpoints.trendingAnimes());
    } catch (error, stackTrace) {
      trendingAnimes.fail(error, stackTrace);
    }
    if (!mounted) return;
    notifyListeners();
  }

  Future<void> fetchTopOngoingAnimes() async {
    if (!topOngoingAnimes.isWaiting) return;

    try {
      topOngoingAnimes.finish(await AnilistMediaEndpoints.topOngoingAnimes());
    } catch (error, stackTrace) {
      topOngoingAnimes.fail(error, stackTrace);
    }
    if (!mounted) return;
    notifyListeners();
  }

  Future<void> fetchMostPopularAnimes() async {
    if (!mostPopularAnimes.isWaiting) return;

    try {
      mostPopularAnimes.finish(await AnilistMediaEndpoints.mostPopularAnimes());
    } catch (error, stackTrace) {
      mostPopularAnimes.fail(error, stackTrace);
    }
    if (!mounted) return;
    notifyListeners();
  }

  Future<void> fetchTrendingMangas() async {
    if (!trendingMangas.isWaiting) return;

    try {
      trendingMangas.finish(await AnilistMediaEndpoints.trendingMangas());
    } catch (error, stackTrace) {
      trendingMangas.fail(error, stackTrace);
    }
    if (!mounted) return;
    notifyListeners();
  }

  Future<void> fetchTopOngoingMangas() async {
    if (!topOngoingMangas.isWaiting) return;

    try {
      topOngoingMangas.finish(await AnilistMediaEndpoints.topOngoingMangas());
    } catch (error, stackTrace) {
      topOngoingMangas.fail(error, stackTrace);
    }
    if (!mounted) return;
    notifyListeners();
  }

  Future<void> fetchMostPopularMangas() async {
    if (!mostPopularMangas.isWaiting) return;

    try {
      mostPopularMangas.finish(await AnilistMediaEndpoints.mostPopularMangas());
    } catch (error, stackTrace) {
      mostPopularMangas.fail(error, stackTrace);
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
