import 'package:flutter/material.dart';
import 'package:utilx/utilities/locale.dart';
import '../../../../modules/database/database.dart';
import '../../../../modules/translator/translations.dart';
import '../../../../modules/translator/translator.dart';
import '../../../components/material_tiles/radio.dart';

List<Widget> getSettingsPreference(
  final BuildContext context,
  final SettingsSchema settings,
  final Future<void> Function() save,
) =>
    <Widget>[
      Builder(
        builder: (final BuildContext context) => MaterialRadioTile<String>(
          title: Text(Translator.t.language()),
          dialogTitle: Text(Translator.t.chooseLanguage()),
          icon: const Icon(Icons.language),
          value: Translator.t.locale.toCodeString(),
          labels: <String, String>{
            for (final TranslationSentences lang in Translator.translations)
              lang.locale.toCodeString():
                  lang.locale.toPrettyString(appendCode: true),
          },
          onChanged: (final String val) async {
            settings.preferences.locale = Locale.parse(val);
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
      MaterialRadioTile<int>(
        title: Text(Translator.t.theme()),
        dialogTitle: Text(Translator.t.chooseTheme()),
        icon: const Icon(Icons.palette),
        value: settings.preferences.useSystemPreferredTheme
            ? 0
            : !settings.preferences.useDarkMode
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
              settings.preferences.useSystemPreferredTheme = true;
              break;

            case 1:
              settings.preferences.useSystemPreferredTheme = false;
              settings.preferences.useDarkMode = false;
              break;

            case 2:
              settings.preferences.useSystemPreferredTheme = false;
              settings.preferences.useDarkMode = true;
              break;
          }

          await save();
        },
      ),
    ];
