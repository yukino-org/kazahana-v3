import 'package:flutter/material.dart';
import './setting_dialog.dart';
import './setting_radio.dart';
import './setting_switch.dart';
import '../../core/models/languages.dart' show LanguageName;
import '../../core/models/player.dart' show Player;
import '../../core/models/translations.dart' show TranslationSentences;
import '../../plugins/database/database.dart';
import '../../plugins/database/schemas/settings/settings.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/state.dart' show AppState;
import '../../plugins/translator/translator.dart';

enum Pages {
  home,
  preference,
  anime,
  manga,
}

class SettingsCategory {
  SettingsCategory(this.name, this.page, this.icon);

  final String name;
  final Pages page;
  final IconData icon;
}

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(
          key: key,
        );

  @override
  State<Page> createState() => PageState();
}

class PageState extends State<Page> {
  final Duration animationDuration = const Duration(milliseconds: 200);
  Pages currentPage = Pages.home;
  final List<SettingsCategory> categories = <SettingsCategory>[
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

  final SettingsSchema settings = DataStore.settings;

  Future<void> saveSettings() async {
    await settings.save();
    AppState.settings.modify(settings);
  }

  Widget getLayouted(final Pages page, final List<Widget> children) =>
      SingleChildScrollView(
        key: ValueKey<Pages>(page),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: remToPx(0.25),
            ),
            ...children,
          ],
        ),
      );

  Widget getPage(final Pages page) {
    switch (page) {
      case Pages.home:
        return getLayouted(
          Pages.home,
          categories
              .map(
                (final SettingsCategory x) => ListTile(
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
                setState(() {
                  settings.locale = val;
                });

                await saveSettings();
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
          <Widget>[
            SettingSwitch(
              title: Translator.t.landscapeVideoPlayer(),
              icon: Icons.screen_lock_landscape,
              desc: Translator.t.landscapeVideoPlayerDetail(),
              value: settings.fullscreenVideoPlayer,
              onChanged: (final bool val) async {
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
              builder: (
                final BuildContext context,
                final StateSetter setState,
              ) =>
                  Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: remToPx(0.5),
                ),
                child: Row(
                  children: <Widget>[
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
                        children: <Widget>[
                          SliderTheme(
                            data: SliderThemeData(
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: remToPx(0.4),
                              ),
                              showValueIndicator: ShowValueIndicator.always,
                            ),
                            child: Slider(
                              label: '${settings.volume}%',
                              value: settings.volume.toDouble(),
                              min: Player.minVolume.toDouble(),
                              max: Player.maxVolume.toDouble(),
                              onChanged: (final double value) {
                                setState(() {
                                  settings.volume = value.toInt();
                                });
                              },
                              onChangeEnd: (final double value) async {
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
              ),
            ),
            SettingDialog(
              title: Translator.t.skipIntroDuration(),
              icon: Icons.fast_forward,
              subtitle: '${settings.introDuration} ${Translator.t.seconds()}',
              builder: (
                final BuildContext context,
                final StateSetter setState,
              ) =>
                  Wrap(
                children: <Widget>[
                  SliderTheme(
                    data: SliderThemeData(
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: remToPx(0.4),
                      ),
                      showValueIndicator: ShowValueIndicator.always,
                    ),
                    child: Slider(
                      label:
                          '${settings.introDuration} ${Translator.t.seconds()}',
                      value: settings.introDuration.toDouble(),
                      min: Player.minIntroLength.toDouble(),
                      max: Player.maxIntroLength.toDouble(),
                      onChanged: (final double value) {
                        setState(() {
                          settings.introDuration = value.toInt();
                        });
                      },
                      onChangeEnd: (final double value) async {
                        setState(() {
                          settings.introDuration = value.toInt();
                        });

                        await saveSettings();
                        this.setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
            SettingDialog(
              title: Translator.t.seekDuration(),
              icon: Icons.fast_forward,
              subtitle: '${settings.seekDuration} ${Translator.t.seconds()}',
              builder: (
                final BuildContext context,
                final StateSetter setState,
              ) =>
                  Wrap(
                children: <Widget>[
                  SliderTheme(
                    data: SliderThemeData(
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: remToPx(0.4),
                      ),
                      showValueIndicator: ShowValueIndicator.always,
                    ),
                    child: Slider(
                      label:
                          '${settings.seekDuration} ${Translator.t.seconds()}',
                      value: settings.seekDuration.toDouble(),
                      min: Player.minSeekLength.toDouble(),
                      max: Player.maxSeekLength.toDouble(),
                      onChanged: (final double value) {
                        setState(() {
                          settings.seekDuration = value.toInt();
                        });
                      },
                      onChangeEnd: (final double value) async {
                        setState(() {
                          settings.seekDuration = value.toInt();
                        });

                        await saveSettings();
                        this.setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
            SettingSwitch(
              title: Translator.t.autoPlay(),
              icon: Icons.slideshow,
              desc: Translator.t.autoPlayDetail(),
              value: settings.autoPlay,
              onChanged: (final bool val) async {
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
              onChanged: (final bool val) async {
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
          <Widget>[
            SettingRadio<MangaDirections>(
              title: Translator.t.mangaReaderDirection(),
              icon: Icons.auto_stories,
              value: settings.mangaReaderDirection,
              labels: <MangaDirections, String>{
                MangaDirections.leftToRight: Translator.t.leftToRight(),
                MangaDirections.rightToLeft: Translator.t.rightToLeft(),
              },
              onChanged: (final MangaDirections val) async {
                setState(() {
                  settings.mangaReaderDirection = val;
                });

                await saveSettings();
              },
            ),
            SettingRadio<MangaSwipeDirections>(
              title: Translator.t.mangaReaderSwipeDirection(),
              icon: Icons.swipe,
              value: settings.mangaReaderSwipeDirection,
              labels: <MangaSwipeDirections, String>{
                MangaSwipeDirections.horizontal: Translator.t.horizontal(),
                MangaSwipeDirections.vertical: Translator.t.vertical(),
              },
              onChanged: (final MangaSwipeDirections val) async {
                setState(() {
                  settings.mangaReaderSwipeDirection = val;
                });

                await saveSettings();
              },
            ),
            SettingRadio<MangaMode>(
              title: Translator.t.mangaReaderMode(),
              icon: Icons.pageview,
              value: settings.mangaReaderMode,
              labels: <MangaMode, String>{
                MangaMode.list: Translator.t.list(),
                MangaMode.page: Translator.t.page(),
              },
              onChanged: (final MangaMode val) async {
                setState(() {
                  settings.mangaReaderMode = val;
                });

                await saveSettings();
              },
            ),
            SettingRadio<MangaMode>(
              title: Translator.t.mangaReaderMode(),
              icon: Icons.pageview,
              value: settings.mangaReaderMode,
              labels: <MangaMode, String>{
                MangaMode.list: Translator.t.list(),
                MangaMode.page: Translator.t.page(),
              },
              onChanged: (final MangaMode val) async {
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
              onChanged: (final bool val) async {
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

  void goToPage(final Pages page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(final BuildContext context) => WillPopScope(
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
                transitionBuilder:
                    (final Widget child, final Animation<double> animation) {
                  final Widget fade = FadeTransition(
                    opacity: animation,
                    child: child,
                  );

                  if (child.key == const ValueKey<Pages>(Pages.home)) {
                    return fade;
                  }

                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: const Offset(0, 0),
                    ).animate(animation),
                    child: fade,
                  );
                },
                layoutBuilder: (
                  final Widget? currentChild,
                  final List<Widget> previousChildren,
                ) =>
                    Stack(
                  alignment: Alignment.topLeft,
                  children: <Widget>[
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                ),
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
