import 'package:flutter/material.dart';
import './about_tile.dart';
import './setting_labels/anime.dart';
import './setting_labels/manga.dart';
import './setting_labels/preference.dart';
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
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
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
    setState(() {});
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
        return getLayouted(Pages.home, <Widget>[
          SizedBox(height: remToPx(1)),
          const AboutTile(),
          SizedBox(height: remToPx(1)),
          ...categories
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
        ]);

      case Pages.preference:
        return getLayouted(
          Pages.preference,
          getPreference(settings, saveSettings),
        );

      case Pages.anime:
        return getLayouted(
          Pages.anime,
          getAnime(settings, saveSettings),
        );

      case Pages.manga:
        return getLayouted(
          Pages.manga,
          getManga(settings, saveSettings),
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
            backgroundColor: Theme.of(context).primaryColor,
            iconTheme: IconTheme.of(context).copyWith(
              color: Colors.white,
            ),
          ),
          body: SingleChildScrollView(
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
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
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
