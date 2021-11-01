import 'package:flutter/material.dart';
import 'package:utilx/utilities/locale.dart';
import '../../../../modules/database/database.dart';
import '../../../../modules/translator/translations.dart';
import '../../../../modules/translator/translator.dart';
import '../setting_radio.dart';

List<Widget> getPreference(
  final SettingsSchema settings,
  final Future<void> Function() save,
) =>
    <Widget>[
      Builder(
        builder: (final BuildContext context) => SettingRadio<String>(
          title: Translator.t.language(),
          dialogTitle: Translator.t.chooseLanguage(),
          icon: Icons.language,
          value: Translator.t.locale.toString(),
          labels: <String, String>{
            for (final TranslationSentences lang in Translator.translations)
              lang.locale.toString():
                  '${lang.locale.code.language} (${lang.locale.toString()})',
          },
          onChanged: (final String val) async {
            settings.locale = val;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  Translator.t.restartAppForChangesToTakeEffect(),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                backgroundColor: Theme.of(context).cardColor,
              ),
            );

            await save();
          },
        ),
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
