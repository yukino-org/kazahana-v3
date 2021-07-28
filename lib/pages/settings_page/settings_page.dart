import 'package:flutter/material.dart';
import '../../core/utils.dart' as utils;
import '../../plugins/state.dart' show AppState;
import '../../plugins/database/database.dart';
import '../../plugins/database/schemas/settings/settings.dart';
import '../../plugins/translator/translator.dart';
import '../../plugins/translator/model.dart' show LanguageCodes, LanguageName;
import './setting_radio.dart';
import './setting_switch.dart';

class SettingsCategory {
  final String name;
  final IconData icon;

  SettingsCategory(this.name, this.icon);
}

enum Pages { home }

class Page extends StatefulWidget {
  const Page({
    Key? key,
  }) : super(
          key: key,
        );

  @override
  State<Page> createState() => PageState();
}

class PageState extends State<Page> {
  final controller = PageController(
    initialPage: Pages.home.index,
    keepPage: true,
  );
  final settings = DataStore.getSettings();

  Future<void> saveSettings() async {
    await settings.save();
    AppState.settings.modify(settings);
  }

  void goToPage(int page) => controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );

  @override
  Widget build(BuildContext context) {
    final Map<SettingsCategory, List<Widget>> labels = {
      SettingsCategory(
        Translator.t.preferences(),
        Icons.invert_colors,
      ): [
        SettingRadio(
          title: Translator.t.language(),
          dialogTitle: Translator.t.chooseLanguage(),
          icon: Icons.language,
          value: settings.locale ?? Translator.t.code.code,
          labels: {
            for (final lang in LanguageCodes.values) lang.code: lang.language,
          },
          onChanged: (val) async {
            if (val is int) {
              setState(() {
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
              });
              await saveSettings();
            }
          },
        ),
        SettingRadio(
          title: Translator.t.theme(),
          dialogTitle: Translator.t.chooseTheme(),
          icon: Icons.palette,
          value: settings.useSystemPreferredTheme
              ? 0
              : !settings.useDarkMode
                  ? 1
                  : 2,
          labels: {
            0: Translator.t.systemPreferredTheme(),
            1: Translator.t.defaultTheme(),
            2: Translator.t.darkMode(),
          },
          onChanged: (val) async {
            if (val is int) {
              setState(() {
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
              });
              await saveSettings();
            }
          },
        ),
        SettingSwitch(
          title: Translator.t.landscapeVideoPlayer(),
          icon: Icons.screen_lock_landscape,
          desc: Translator.t.landscapeVideoPlayerDetail(),
          value: settings.fullscreenVideoPlayer,
          onChanged: (val) async {
            if (val is bool) {
              setState(() {
                settings.fullscreenVideoPlayer = val;
              });

              await settings.save();
            }
          },
        ),
        SettingRadio(
          title: Translator.t.mangaReaderDirection(),
          icon: Icons.auto_stories,
          value: settings.mangaReaderDirection,
          labels: {
            MangaDirections.leftToRight: Translator.t.leftToRight(),
            MangaDirections.rightToLeft: Translator.t.rightToLeft(),
          },
          onChanged: (val) async {
            if (val is MangaDirections) {
              setState(() {
                settings.mangaReaderDirection = val;
              });

              await settings.save();
            }
          },
        ),
        SettingRadio(
          title: Translator.t.mangaReaderSwipeDirection(),
          icon: Icons.swipe,
          value: settings.mangaReaderSwipeDirection,
          labels: {
            MangaSwipeDirections.horizontal: Translator.t.horizontal(),
            MangaSwipeDirections.vertical: Translator.t.vertical(),
          },
          onChanged: (val) async {
            if (val is MangaSwipeDirections) {
              setState(() {
                settings.mangaReaderSwipeDirection = val;
              });

              await settings.save();
            }
          },
        ),
      ]
    };

    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              Translator.t.settings(),
            ),
          ),
          body: SafeArea(
            child: PageView(
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: utils.remToPx(0.25),
                      ),
                      ...labels.keys
                          .toList()
                          .asMap()
                          .map(
                            (i, x) => MapEntry(
                              i,
                              ListTile(
                                leading: Icon(
                                  x.icon,
                                  color: Theme.of(context).primaryColor,
                                ),
                                title: Text(x.name),
                                onTap: () {
                                  goToPage(i + Pages.values.length);
                                },
                              ),
                            ),
                          )
                          .values
                          .toList()
                    ],
                  ),
                ),
                ...labels.keys
                    .map(
                      (x) => SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: utils.remToPx(0.25),
                          ),
                          child: Column(
                            children: labels[x]!,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          if (controller.page == Pages.home.index) {
            Navigator.of(context).pop();
            return true;
          }

          goToPage(Pages.home.index);
          return false;
        });
  }
}
