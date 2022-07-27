import 'package:utilx/locale.dart';
import '../app/exports.dart';
import '../database/exports.dart';
import 'translations/exports.dart';

abstract class Translator {
  static const Locale defaultLocale = Locale(LanguageCodes.en);

  static final List<Translations> all = <Translations>[
    EnTranslation(),
  ];

  static Translations currentTranslation = getDefaultLocaleTranslation();

  static Future<void> initialize() async {
    updateCurrentTranslation();

    AppEvents.stream.listen((final AppEvent event) {
      if (event != AppEvent.settingsChange) return;
      updateCurrentTranslation();
    });
  }

  static void updateCurrentTranslation() {
    currentTranslation = (SettingsDatabase.settings.locale != null
            ? getTranslation(SettingsDatabase.settings.locale!)
            : null) ??
        getDefaultLocaleTranslation();
    AppEvents.controller.add(AppEvent.translationsChange);
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

  static Locale get locale => currentTranslation.locale;

  static String get identifier =>
      '${locale.toCodeString()}+$currentTranslation';
}
