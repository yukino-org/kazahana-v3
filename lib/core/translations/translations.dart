import 'package:utilx/locale.dart';
import '../database/exports.dart';
import 'model.dart';
import 'sentences/exports.dart';

abstract class Translations {
  static const Locale defaultLocale = Locale(LanguageCodes.en);

  static late TranslationSentences t;
  static final List<TranslationSentences> all = <TranslationSentences>[
    EnSentences(),
  ];

  static Future<void> initialize() async {
    t = (SettingsDatabase.settings.locale != null
            ? getTranslation(SettingsDatabase.settings.locale!)
            : null) ??
        getDefaultLocaleTranslation();
  }

  static TranslationSentences getDefaultLocaleTranslation() =>
      getTranslation(defaultLocale)!;

  static TranslationSentences? getTranslation(final Locale locale) {
    int prevMatchThreshold = 0;
    TranslationSentences? sentences;

    for (final TranslationSentences x in all) {
      final int threshold = x.locale.compare(locale);
      if (threshold > prevMatchThreshold) {
        prevMatchThreshold = threshold;
        sentences = x;
      }
    }

    return sentences;
  }
}
