import 'package:flutter/material.dart';
import 'package:tenka/tenka.dart';
import '../../../core/exports.dart';
import '../../../core/kitsu/endpoints/seasonal_trends.dart';

class UnderScoreHomePageProvider with ChangeNotifier {
  TenkaType type = TenkaType.anime;

  final StatedValue<KitsuSeasonTrendsData> trendingAnimes =
      StatedValue<KitsuSeasonTrendsData>();
  final StatedValue<List<KitsuAnime>> topOngoingAnimes =
      StatedValue<List<KitsuAnime>>();
  final StatedValue<List<KitsuAnime>> mostPopularAnimes =
      StatedValue<List<KitsuAnime>>();

  final StatedValue<List<KitsuManga>> topOngoingMangas =
      StatedValue<List<KitsuManga>>();
  final StatedValue<List<KitsuManga>> mostPopularMangas =
      StatedValue<List<KitsuManga>>();

  void initialize() {
    fetch(type);
  }

  void setType(final TenkaType type) {
    this.type = type;
    fetch(type);
    notifyListeners();
  }

  void fetch(final TenkaType type) {
    switch (type) {
      case TenkaType.anime:
        fetchTrendingAnimes();
        fetchTopOngoingAnimes();
        fetchMostPopularAnimes();
        break;

      case TenkaType.manga:
        fetchTopOngoingMangas();
        fetchMostPopularMangas();
        break;
    }
  }

  Future<void> fetchTrendingAnimes() async {
    if (!trendingAnimes.isWaiting) return;

    try {
      trendingAnimes
          .finish(await KitsuSeasonTrends.getTrendingAnimesBasedOnUpvotes());
    } catch (error, stackTrace) {
      trendingAnimes.fail(error, stackTrace);
    }
    notifyListeners();
  }

  Future<void> fetchTopOngoingAnimes() async {
    if (!topOngoingAnimes.isWaiting) return;

    try {
      topOngoingAnimes.finish(await KitsuAnimeEndpoints.topOngoingAnimes());
    } catch (error, stackTrace) {
      topOngoingAnimes.fail(error, stackTrace);
    }
    notifyListeners();
  }

  Future<void> fetchMostPopularAnimes() async {
    if (!mostPopularAnimes.isWaiting) return;

    try {
      mostPopularAnimes.finish(await KitsuAnimeEndpoints.mostPopularAnimes());
    } catch (error, stackTrace) {
      mostPopularAnimes.fail(error, stackTrace);
    }
    notifyListeners();
  }

  Future<void> fetchTopOngoingMangas() async {
    if (!topOngoingMangas.isWaiting) return;

    try {
      topOngoingMangas.finish(await KitsuMangaEndpoints.topOngoingMangas());
    } catch (error, stackTrace) {
      topOngoingMangas.fail(error, stackTrace);
    }
    notifyListeners();
  }

  Future<void> fetchMostPopularMangas() async {
    if (!mostPopularMangas.isWaiting) return;

    try {
      mostPopularMangas.finish(await KitsuMangaEndpoints.mostPopularMangas());
    } catch (error, stackTrace) {
      mostPopularMangas.fail(error, stackTrace);
    }
    notifyListeners();
  }
}
