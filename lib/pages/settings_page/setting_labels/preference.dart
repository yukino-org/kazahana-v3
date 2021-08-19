import 'package:flutter/material.dart';
import '../../../core/models/languages.dart' show LanguageName;
import '../../../core/models/translations.dart' show TranslationSentences;
import '../../../plugins/database/schemas/settings/settings.dart';
import '../../../plugins/translator/translator.dart';
import '../setting_radio.dart';

List<Widget> getPreference(
  final SettingsSchema settings,
  final Future<void> Function() save,
) =>
    <Widget>[
      SettingRadio<String>(
        title: Translator.t.language(),
        dialogTitle: Translator.t.chooseLanguage(),
        icon: Icons.language,
        value: settings.locale ?? Translator.t.code.code,
        labels: <String, String>{
          for (final TranslationSentences lang
              in Translator.translations.values)
            lang.code.code: lang.code.language,
        },
        onChanged: (final String val) async {
          settings.locale = val;

          await save();
        },
      ),
      SettingRadio<int>(
        title: Translator.t.theme(),
        dialogTitle: Translator.t.chooseTheme(),
        icon: Icons.palette,
        value: settings.useSystemPreferredTheme
            ? 0
            : !settings.useDarkMode
                ? 1
                : 2,
        labels: <int, String>{
          0: Translator.t.systemPreferredTheme(),
          1: Translator.t.defaultTheme(),
          2: Translator.t.darkMode(),
        },
        onChanged: (final int val) async {
          switch (val) {
            case 0:
              settings.useSystemPreferredTheme = true;
              break;

            case 1:
              settings.useSystemPreferredTheme = false;
              settings.useDarkMode = false;
              break;

            case 2:
              settings.useSystemPreferredTheme = false;
              settings.useDarkMode = true;
              break;
          }

          await save();
        },
      ),
    ];
