import 'package:flutter/material.dart';
import 'package:tenka/tenka.dart';
import '../../../core/exports.dart';

class UnderScoreHomePageProvider with ChangeNotifier {
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
    notifyListeners();
  }

  Future<void> fetchTopOngoingAnimes() async {
    if (!topOngoingAnimes.isWaiting) return;

    try {
      topOngoingAnimes.finish(await AnilistMediaEndpoints.topOngoingAnimes());
    } catch (error, stackTrace) {
      topOngoingAnimes.fail(error, stackTrace);
    }
    notifyListeners();
  }

  Future<void> fetchMostPopularAnimes() async {
    if (!mostPopularAnimes.isWaiting) return;

    try {
      mostPopularAnimes.finish(await AnilistMediaEndpoints.mostPopularAnimes());
    } catch (error, stackTrace) {
      mostPopularAnimes.fail(error, stackTrace);
    }
    notifyListeners();
  }

  Future<void> fetchTrendingMangas() async {
    if (!trendingMangas.isWaiting) return;

    try {
      trendingMangas.finish(await AnilistMediaEndpoints.trendingMangas());
    } catch (error, stackTrace) {
      trendingMangas.fail(error, stackTrace);
    }
    notifyListeners();
  }

  Future<void> fetchTopOngoingMangas() async {
    if (!topOngoingMangas.isWaiting) return;

    try {
      topOngoingMangas.finish(await AnilistMediaEndpoints.topOngoingMangas());
    } catch (error, stackTrace) {
      topOngoingMangas.fail(error, stackTrace);
    }
    notifyListeners();
  }

  Future<void> fetchMostPopularMangas() async {
    if (!mostPopularMangas.isWaiting) return;

    try {
      mostPopularMangas.finish(await AnilistMediaEndpoints.mostPopularMangas());
    } catch (error, stackTrace) {
      mostPopularMangas.fail(error, stackTrace);
    }
    notifyListeners();
  }
}
