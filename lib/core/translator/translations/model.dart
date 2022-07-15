import 'package:utilx/locale.dart';

abstract class Translations {
  String anime();
  String manga();
  String searchAnime();
  String searchManga();

  Locale get locale;
}
