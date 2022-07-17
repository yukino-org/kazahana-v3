import 'package:utilx/locale.dart';

abstract class Translations {
  String anime();
  String manga();
  String searchAnime();
  String searchManga();
  String mostPopularAnimes();
  String topOngoingAnimes();
  String mostPopularMangas();
  String topOngoingMangas();
  String current();
  String finished();
  String tba();
  String unreleased();
  String upcoming();
  String winter();
  String spring();
  String summer();
  String autumn();

  Locale get locale;
}
