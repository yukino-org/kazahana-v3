import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:utilx/locale.dart';
import 'package:utilx/utilx.dart';
import '../app/exports.dart';
import '../database/exports.dart';

part 'translation.g.dart';

abstract class Translator {
  static const Locale defaultLocale = LocalesRepository.en;

  static late Translation currentTranslation;

  static Future<void> initialize() async {
    await updateCurrentTranslation();

    AppEvents.stream.listen((final AppEvent event) async {
      if (event != AppEvent.settingsChange) return;
      await updateCurrentTranslation();
    });
  }

  static Future<void> updateCurrentTranslation() async {
    final Locale? settingsLocale = SettingsDatabase.settings.locale;
    final Locale locale =
        settingsLocale != null && hasTranslation(settingsLocale)
            ? settingsLocale
            : defaultLocale;
    currentTranslation = await parseTranslation(locale);
    AppEvents.controller.add(AppEvent.translationsChange);
  }

  static bool hasTranslation(final Locale locale) =>
      Translation.availableLocales.contains(locale.code);

  static Future<Translation> parseTranslation(final Locale locale) async {
    final String content =
        await rootBundle.loadString('assets/translations/${locale.code}.json');
    final JsonMap parsed = json.decode(content) as JsonMap;
    return Translation(parsed);
  }

  static Locale get locale => currentTranslation.locale;

  static String get identifier => locale.code;
}
