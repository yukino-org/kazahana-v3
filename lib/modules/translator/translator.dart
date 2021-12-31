import 'dart:io';
import 'package:utilx/utilities/locale.dart';
import './translations/en.dart' as en;
import './translations/pt_br.dart' as pt_br;
import './translations/es.dart' as es;
import 'translations.dart';

abstract class Translator {
  static final List<TranslationSentences> translations = <TranslationSentences>[
    en.Sentences(),
    pt_br.Sentences(),
    es.Sentences(),
  ];

  static TranslationSentences? _t;

  static TranslationSentences? tryGetTranslation(final Locale locale) {
    TranslationSentences? translation;
    int threshold = 0;

    for (final TranslationSentences x in translations) {
      final int nThresh = x.locale.compare(locale);
      if (nThresh > threshold) {
        translation = x;
        threshold = nThresh;
      }
    }

    return translation;
  }

  static TranslationSentences getDefaultTranslation() =>
      translations.firstWhere(
        (final TranslationSentences x) =>
            x.locale == const Locale(LanguageCodes.en),
      );

  static TranslationSentences getSupportedTranslation() {
    final Locale? platformLocale = Locale.tryParse(Platform.localeName);
    final TranslationSentences? platformSentences =
        platformLocale != null ? tryGetTranslation(platformLocale) : null;

    return platformSentences ?? getDefaultTranslation();
  }

  static TranslationSentences get t => _t!;
  static set t(final TranslationSentences translation) {
    _t = translation;
  }

  static bool get loaded => _t != null;
}
