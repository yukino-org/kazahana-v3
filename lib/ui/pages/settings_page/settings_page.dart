import 'package:flutter/material.dart';
import './setting_labels/about.dart';
import './setting_labels/anime.dart';
import './setting_labels/developers.dart';
import './setting_labels/manga.dart';
import './setting_labels/preference.dart';
import '../../../config/defaults.dart';
import '../../../modules/app/state.dart';
import '../../../modules/database/database.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/translator/translator.dart';
import '../../../modules/utils/utils.dart';
import '../../components/material_tiles/base.dart';
import '../../components/size_aware_builder.dart';

enum Pages {
  preference,
  anime,
  manga,
  developers,
  about,
}

class SettingsCategory {
  SettingsCategory(this.name, this.page, this.icon, this.builder);

  final String name;
  final Pages page;
  final IconData icon;
  final List<Widget> Function(
    BuildContext,
    SettingsSchema,
    Future<void> Function(),
  ) builder;
}

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  final List<SettingsCategory> categories = <SettingsCategory>[
    SettingsCategory(
      Translator.t.preferences(),
      Pages.preference,
      Icons.invert_colors,
      getSettingsPreference,
    ),
    SettingsCategory(
      Translator.t.anime(),
      Pages.anime,
      Icons.play_arrow,
      getSettingsAnime,
    ),
    SettingsCategory(
      Translator.t.manga(),
      Pages.manga,
      Icons.book,
      getSettingsManga,
    ),
    SettingsCategory(
      Translator.t.developers(),
      Pages.developers,
      Icons.developer_mode,
      getSettingsDevelopers,
    ),
    SettingsCategory(
      Translator.t.about(),
      Pages.about,
      Icons.info,
      getSettingsAbout,
    ),
  ];

  late SettingsCategory currentCategory = categories.first;

  final SettingsSchema settings = SettingsBox.get();

  Future<void> saveSettings() async {
    AppState.settings.value = settings;
    await SettingsBox.save(AppState.settings.value);

    if (mounted) {
      setState(() {});
    }
  }

  List<Widget> buildCategoryChildren(
    final BuildContext context, {
    final bool popOnPressed = false,
  }) =>
      <Widget>[
        SizedBox(height: remToPx(0.3)),
        ...categories
            .map(
              (final SettingsCategory x) => MaterialTile(
                icon: Icon(
                  x.icon,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(x.name),
                active: currentCategory == x,
                onTap: () {
                  goToPage(x);

                  if (popOnPressed) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            )
            .toList()
      ];

  void goToPage(final SettingsCategory category) {
    if (mounted) {
      setState(() {
        currentCategory = category;
      });
    }
  }

  Future<void> showCategories(final BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (final BuildContext context) => ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: remToPx(1),
              right: remToPx(1),
              top: remToPx(0.6),
            ),
            child: Text(
              Translator.t.settings(),
              style: FunctionUtils.withValue(
                Theme.of(context),
                (final ThemeData theme) => TextStyle(
                  color: theme.primaryColor,
                  fontSize: theme.textTheme.headline6?.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ...buildCategoryChildren(
            context,
            popOnPressed: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => SizeAwareBuilder(
        builder: (final BuildContext context, final ResponsiveSize size) {
          final double sideBarWidth =
              size.isMd ? size.width / (size.isLg ? 4.5 : 4) : 0;
          final double seperatorWidth = remToPx(0.05);
          final double pageHeight = size.height - kToolbarHeight;
          final double pageWidth = size.width - sideBarWidth - seperatorWidth;

          return Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${Translator.t.settings()} - ',
                    key: ValueKey<Pages>(currentCategory.page),
                  ),
                  AnimatedSwitcher(
                    duration: Defaults.animationsSlower,
                    child: Text(
                      currentCategory.name,
                      key: ValueKey<Pages>(currentCategory.page),
                    ),
                    transitionBuilder: (
                      final Widget child,
                      final Animation<double> animation,
                    ) {
                      final Widget fade = FadeTransition(
                        opacity: animation,
                        child: child,
                      );

                      if (child.key != ValueKey<Pages>(currentCategory.page)) {
                        return fade;
                      }

                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
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
                ],
              ),
              backgroundColor: Theme.of(context).primaryColor,
              iconTheme: IconTheme.of(context).copyWith(
                color: Colors.white,
              ),
            ),
            body: Row(
              children: <Widget>[
                if (sideBarWidth != 0)
                  SizedBox(
                    height: pageHeight,
                    width: sideBarWidth,
                    child: SingleChildScrollView(
                      child: Column(
                        children: buildCategoryChildren(context),
                      ),
                    ),
                  ),
                Container(
                  height: pageHeight,
                  width: seperatorWidth,
                  color: Theme.of(context).cardColor,
                  child: const SizedBox.expand(),
                ),
                SizedBox(
                  height: pageHeight,
                  width: pageWidth,
                  child: SingleChildScrollView(
                    child: AnimatedSwitcher(
                      switchOutCurve: Curves.easeInOut,
                      duration: Defaults.animationsNormal,
                      child: Column(
                        key: ValueKey<Pages>(currentCategory.page),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: remToPx(0.3)),
                          ...currentCategory.builder(
                            context,
                            settings,
                            saveSettings,
                          ),
                          SizedBox(height: remToPx(0.3)),
                        ],
                      ),
                      transitionBuilder: (
                        final Widget child,
                        final Animation<double> animation,
                      ) {
                        final Widget fade = FadeTransition(
                          opacity: animation,
                          child: child,
                        );

                        if (child.key !=
                            ValueKey<Pages>(currentCategory.page)) {
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
              ],
            ),
            floatingActionButton: !size.isMd
                ? FloatingActionButton(
                    child: const Icon(Icons.list),
                    onPressed: () async {
                      await showCategories(context);
                    },
                  )
                : null,
          );
        },
      );
}
