import 'package:flutter/material.dart';
import '../../core/utils.dart' as utils;
import '../../core/models/player.dart' show Player;
import '../../plugins/state.dart' show AppState;
import '../../plugins/database/database.dart';
import '../../plugins/database/schemas/settings/settings.dart';
import '../../plugins/translator/translator.dart';
import '../../core/models/languages.dart' show LanguageName;
import './setting_radio.dart';
import './setting_switch.dart';
import './setting_dialog.dart';

enum Pages {
  home,
  preference,
  anime,
  manga,
}

class SettingsCategory {
  final String name;
  final Pages page;
  final IconData icon;

  SettingsCategory(this.name, this.page, this.icon);
}

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
  final animationDuration = const Duration(milliseconds: 200);
  Pages currentPage = Pages.home;
  final List<SettingsCategory> categories = [
    SettingsCategory(
      Translator.t.preferences(),
      Pages.preference,
      Icons.invert_colors,
    ),
    SettingsCategory(
      Translator.t.anime(),
      Pages.anime,
      Icons.play_arrow,
    ),
    SettingsCategory(
      Translator.t.manga(),
      Pages.manga,
      Icons.book,
    ),
  ];

  final settings = DataStore.getSettings();

  Future<void> saveSettings() async {
    await settings.save();
    AppState.settings.modify(settings);
  }

  Widget getLayouted(Pages page, List<Widget> children) {
    return SingleChildScrollView(
      key: ValueKey(page),
      child: Column(
        children: [
          SizedBox(
            height: utils.remToPx(0.25),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget getPage(Pages page) {
    switch (page) {
      case Pages.home:
        return getLayouted(
          Pages.home,
          categories
              .map(
                (x) => ListTile(
                  leading: Icon(
                    x.icon,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(x.name),
                  onTap: () {
                    goToPage(x.page);
                  },
                ),
              )
              .toList(),
        );

      case Pages.preference:
        return getLayouted(
          Pages.preference,
          [
            SettingRadio(
              title: Translator.t.language(),
              dialogTitle: Translator.t.chooseLanguage(),
              icon: Icons.language,
              value: settings.locale ?? Translator.t.code.code,
              labels: {
                for (final lang in Translator.translations.values)
                  lang.code.code: lang.code.language,
              },
              onChanged: (val) async {
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
              },
            ),
          ],
        );

      case Pages.anime:
        return getLayouted(
          Pages.anime,
          [
            SettingSwitch(
              title: Translator.t.landscapeVideoPlayer(),
              icon: Icons.screen_lock_landscape,
              desc: Translator.t.landscapeVideoPlayerDetail(),
              value: settings.fullscreenVideoPlayer,
              onChanged: (val) async {
                setState(() {
                  settings.fullscreenVideoPlayer = val;
                });

                await saveSettings();
              },
            ),
            SettingDialog(
              title: Translator.t.volume(),
              icon: Icons.volume_up,
              subtitle: '${settings.volume}%',
              builder: (context, setState) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: utils.remToPx(0.5),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_mute),
                        onPressed: () {
                          setState(() {
                            settings.volume = Player.minVolume;
                          });
                        },
                      ),
                      Expanded(
                        child: Wrap(
                          direction: Axis.horizontal,
                          children: [
                            SliderTheme(
                              data: SliderThemeData(
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: utils.remToPx(0.4),
                                ),
                                showValueIndicator: ShowValueIndicator.always,
                              ),
                              child: Slider(
                                label: '${settings.volume}%',
                                value: settings.volume.toDouble(),
                                min: Player.minVolume.toDouble(),
                                max: Player.maxVolume.toDouble(),
                                onChanged: (value) {
                                  setState(() {
                                    settings.volume = value.toInt();
                                  });
                                },
                                onChangeEnd: (value) async {
                                  setState(() {
                                    settings.volume = value.toInt();
                                  });

                                  await saveSettings();
                                  this.setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () {
                          setState(() {
                            settings.volume = Player.maxVolume;
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            SettingDialog(
              title: Translator.t.skipIntroDuration(),
              icon: Icons.fast_forward,
              subtitle: '${settings.introDuration} ${Translator.t.seconds()}',
              builder: (context, setState) {
                return Wrap(
                  direction: Axis.horizontal,
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: utils.remToPx(0.4),
                        ),
                        showValueIndicator: ShowValueIndicator.always,
                      ),
                      child: Slider(
                        label:
                            '${settings.introDuration} ${Translator.t.seconds()}',
                        value: settings.introDuration.toDouble(),
                        min: Player.minIntroLength.toDouble(),
                        max: Player.maxIntroLength.toDouble(),
                        onChanged: (value) {
                          setState(() {
                            settings.introDuration = value.toInt();
                          });
                        },
                        onChangeEnd: (value) async {
                          setState(() {
                            settings.introDuration = value.toInt();
                          });

                          await saveSettings();
                          this.setState(() {});
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            SettingDialog(
              title: Translator.t.seekDuration(),
              icon: Icons.fast_forward,
              subtitle: '${settings.seekDuration} ${Translator.t.seconds()}',
              builder: (context, setState) {
                return Wrap(
                  direction: Axis.horizontal,
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: utils.remToPx(0.4),
                        ),
                        showValueIndicator: ShowValueIndicator.always,
                      ),
                      child: Slider(
                        label:
                            '${settings.seekDuration} ${Translator.t.seconds()}',
                        value: settings.seekDuration.toDouble(),
                        min: Player.minSeekLength.toDouble(),
                        max: Player.maxSeekLength.toDouble(),
                        onChanged: (value) {
                          setState(() {
                            settings.seekDuration = value.toInt();
                          });
                        },
                        onChangeEnd: (value) async {
                          setState(() {
                            settings.seekDuration = value.toInt();
                          });

                          await saveSettings();
                          this.setState(() {});
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            SettingSwitch(
              title: Translator.t.autoPlay(),
              icon: Icons.slideshow,
              desc: Translator.t.autoPlayDetail(),
              value: settings.autoPlay,
              onChanged: (val) async {
                setState(() {
                  settings.autoPlay = val;
                });

                await saveSettings();
              },
            ),
            SettingSwitch(
              title: Translator.t.autoNext(),
              icon: Icons.skip_next,
              desc: Translator.t.autoNextDetail(),
              value: settings.autoNext,
              onChanged: (val) async {
                setState(() {
                  settings.autoNext = val;
                });

                await saveSettings();
              },
            ),
          ],
        );

      case Pages.manga:
        return getLayouted(
          Pages.manga,
          [
            SettingRadio(
              title: Translator.t.mangaReaderDirection(),
              icon: Icons.auto_stories,
              value: settings.mangaReaderDirection,
              labels: {
                MangaDirections.leftToRight: Translator.t.leftToRight(),
                MangaDirections.rightToLeft: Translator.t.rightToLeft(),
              },
              onChanged: (MangaDirections val) async {
                setState(() {
                  settings.mangaReaderDirection = val;
                });

                await saveSettings();
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
              onChanged: (MangaSwipeDirections val) async {
                setState(() {
                  settings.mangaReaderSwipeDirection = val;
                });

                await saveSettings();
              },
            ),
            SettingRadio(
              title: Translator.t.mangaReaderMode(),
              icon: Icons.pageview,
              value: settings.mangaReaderMode,
              labels: {
                MangaMode.list: Translator.t.list(),
                MangaMode.page: Translator.t.page(),
              },
              onChanged: (MangaMode val) async {
                setState(() {
                  settings.mangaReaderMode = val;
                });

                await saveSettings();
              },
            ),
            SettingRadio(
              title: Translator.t.mangaReaderMode(),
              icon: Icons.pageview,
              value: settings.mangaReaderMode,
              labels: {
                MangaMode.list: Translator.t.list(),
                MangaMode.page: Translator.t.page(),
              },
              onChanged: (MangaMode val) async {
                setState(() {
                  settings.mangaReaderMode = val;
                });

                await saveSettings();
              },
            ),
            SettingSwitch(
              title: Translator.t.doubleTapToSwitchChapter(),
              icon: Icons.double_arrow,
              desc: Translator.t.doubleTapToSwitchChapterDetail(),
              value: settings.doubleClickSwitchChapter,
              onChanged: (val) async {
                setState(() {
                  settings.doubleClickSwitchChapter = val;
                });

                await saveSettings();
              },
            ),
          ],
        );
    }
  }

  void goToPage(Pages page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Translator.t.settings(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: AnimatedSwitcher(
              switchOutCurve: Curves.easeInOut,
              duration: animationDuration,
              child: getPage(currentPage),
              transitionBuilder: (child, animation) {
                final fade = FadeTransition(
                  opacity: animation,
                  child: child,
                );

                if (child.key == const ValueKey(Pages.home)) {
                  return fade;
                }

                return SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.1),
                    end: const Offset(0, 0),
                  ).animate(animation),
                  child: fade,
                );
              },
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.topLeft,
                  children: <Widget>[
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
            ),
          ),
        ),
      ),
      onWillPop: () async {
        if (currentPage == Pages.home) {
          Navigator.of(context).pop();
          return true;
        }

        goToPage(Pages.home);
        return false;
      },
    );
  }
}
