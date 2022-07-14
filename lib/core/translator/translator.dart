import 'package:utilx/locale.dart';
import '../database/exports.dart';
import 'translations/exports.dart';

abstract class Translator {
  static const Locale defaultLocale = Locale(LanguageCodes.en);

  static late Translations t;
  static final List<Translations> all = <Translations>[
    EnTranslation(),
  ];

  static Future<void> initialize() async {
    t = (SettingsDatabase.settings.locale != null
            ? getTranslation(SettingsDatabase.settings.locale!)
            : null) ??
        getDefaultLocaleTranslation();
  }

  static Translations getDefaultLocaleTranslation() =>
      getTranslation(defaultLocale)!;

  static Translations? getTranslation(final Locale locale) {
    int prevMatchThreshold = 0;
    Translations? sentences;

    for (final Translations x in all) {
      final int threshold = x.locale.compare(locale);
      if (threshold > prevMatchThreshold) {
        prevMatchThreshold = threshold;
        sentences = x;
      }
    }

    return sentences;
  }
}
