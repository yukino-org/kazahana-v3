import 'package:flutter/material.dart';
import 'package:tenka/tenka.dart';
import 'package:utilx/utils.dart';
import '../../../core/exports.dart';

class SearchPageProvider with ChangeNotifier {
  TenkaType type = TenkaType.anime;
  final StatedValue<TripleTuple<String, TenkaType, List<dynamic>>> results =
      StatedValue<TripleTuple<String, TenkaType, List<dynamic>>>();

  void setType(final TenkaType type) {
    this.type = type;
    notifyListeners();
  }

  void reset() {
    results.waiting();
    notifyListeners();
  }

  Future<void> search(final String terms) async {
    results.loading();
    notifyListeners();

    try {
      final List<dynamic> values;
      switch (type) {
        case TenkaType.anime:
          values = await KitsuAnimeEndpoints.search(terms);
          break;

        case TenkaType.manga:
          values = await KitsuMangaEndpoints.search(terms);
          break;
      }
      results.finish(
        TripleTuple<String, TenkaType, List<dynamic>>(terms, type, values),
      );
    } catch (err, trace) {
      results.fail(err, trace);
    }
    notifyListeners();
  }
}
