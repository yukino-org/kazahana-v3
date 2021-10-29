import 'package:animations/animations.dart';
import 'package:collection/collection.dart';
import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import '../../../modules/database/database.dart';
import '../../../modules/extensions/extensions.dart';
import '../../../modules/helpers/assets.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/state/holder.dart';
import '../../../modules/state/hooks.dart';
import '../../../modules/state/states.dart';
import '../../../modules/translator/translator.dart';
import '../../../modules/utils/utils.dart';
import '../../components/error_widget.dart';
import '../../components/network_image_fallback.dart';
import '../../router.dart';
import '../anime_page/anime_page.dart' as anime_page;
import '../manga_page/manga_page.dart' as manga_page;

extension PluginRoutes on ExtensionType {
  String route() {
    switch (this) {
      case ExtensionType.anime:
        return RouteNames.animePage;

      case ExtensionType.manga:
        return RouteNames.mangaPage;
    }
  }

  Map<String, String> params({
    required final String plugin,
    required final String src,
  }) {
    switch (this) {
      case ExtensionType.anime:
        return anime_page.PageArguments(src: src, plugin: plugin).toJson();

      case ExtensionType.manga:
        return manga_page.PageArguments(src: src, plugin: plugin).toJson();
    }
  }
}

class CurrentPlugin {
  CurrentPlugin({
    required final this.type,
    required final this.plugin,
  });

  ExtensionType type;
  BaseExtractor plugin;
}

class _SearchInfo extends SearchInfo {
  _SearchInfo({
    required final String title,
    required final String url,
    required final String locale,
    required final this.pluginName,
    required final this.pluginId,
    required final this.pluginType,
    final ImageDescriber? thumbnail,
  }) : super(
          title: title,
          url: url,
          thumbnail: thumbnail,
          locale: locale,
        );

  final String pluginName;
  final String pluginId;
  final ExtensionType pluginType;
}

class PageArguments {
  PageArguments({
    required final this.terms,
    required final this.autoSearch,
    required final this.pluginType,
  });

  factory PageArguments.fromJson(final Map<String, String> json) =>
      PageArguments(
        terms: json['terms'],
        autoSearch: json['autoSearch'] == 'true',
        pluginType: ExtensionType.values.firstWhereOrNull(
          (final ExtensionType x) => x.type == json['pluginType'],
        ),
      );

  String? terms;
  bool? autoSearch;
  ExtensionType? pluginType;

  Map<String, String> toJson() {
    final Map<String, String> json = <String, String>{};

    if (terms != null) {
      json['terms'] = terms!;
    }

    if (autoSearch != null) {
      json['autoSearch'] = autoSearch.toString();
    }

    if (pluginType != null) {
      json['pluginType'] = pluginType!.type;
    }

    return json;
  }
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

class _PageState extends State<Page> with HooksMixin {
  List<String> animePlugins = ExtensionsManager.animes.keys.toList();
  List<String> mangaPlugins = ExtensionsManager.mangas.keys.toList();

  CurrentPlugin? currentPlugin;
  StatefulValueHolder<List<_SearchInfo>?> results =
      StatefulValueHolder<List<_SearchInfo>?>(null);

  ExtensionType popupPluginType = ExtensionType.anime;
  PageArguments? args;

  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _setCurrentPreferredPlugin();

    onReady(() async {
      if (mounted) {
        args = PageArguments.fromJson(
          ParsedRouteInfo.fromSettings(ModalRoute.of(context)!.settings).params,
        );

        if (args?.pluginType != null) {
          setState(() {
            _setCurrentPreferredPlugin(args!.pluginType);
          });
        }

        if (args?.terms?.isNotEmpty ?? false) {
          setState(() {
            textController.text = args!.terms!;
          });

          if (currentPlugin != null &&
              currentPlugin!.type == args!.pluginType &&
              (args?.autoSearch ?? false)) {
            args!.autoSearch = false;
            await search();
          }
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    maybeEmitReady();
  }

  void _setCurrentPreferredPlugin([final ExtensionType? _pluginType]) {
    final PreferencesSchema preferences = PreferencesBox.get();
    final ExtensionType? pluginType =
        _pluginType ?? preferences.lastSelectedSearch.lastSelectedType;

    if (pluginType != null) {
      BaseExtractor? ext;

      switch (pluginType) {
        case ExtensionType.anime:
          ext = ExtensionsManager
              .animes[preferences.lastSelectedSearch.lastSelectedAnimePlugin];
          break;

        case ExtensionType.manga:
          ext = ExtensionsManager
              .mangas[preferences.lastSelectedSearch.lastSelectedMangaPlugin];
          break;
      }

      if (ext != null) {
        currentPlugin = CurrentPlugin(type: pluginType, plugin: ext);
        popupPluginType = pluginType;
      }
    }
  }

  Future<void> search() async {
    if (mounted && currentPlugin != null) {
      setState(() {
        results.resolving(null);
      });

      try {
        final List<SearchInfo> searches = await currentPlugin!.plugin.search(
          textController.text,
          Translator.t.locale.code.name,
        );

        if (mounted) {
          setState(() {
            results.resolve(
              searches
                  .map(
                    (final SearchInfo x) => _SearchInfo(
                      title: x.title,
                      url: x.url,
                      thumbnail: x.thumbnail,
                      locale: x.locale,
                      pluginId: currentPlugin!.plugin.id,
                      pluginName: currentPlugin!.plugin.name,
                      pluginType: currentPlugin!.type,
                    ),
                  )
                  .toList(),
            );
          });
        }
      } catch (err) {
        if (mounted) {
          setState(() {
            results.fail(null);
          });
        }
      }
    }
  }

  Future<void> selectPlugins(final BuildContext context) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (
        final BuildContext context,
        final Animation<double> a1,
        final Animation<double> a2,
      ) =>
          StatefulBuilder(
        builder: (final BuildContext context, final StateSetter setState) =>
            PageTransitionSwitcher(
          transitionBuilder: (
            final Widget child,
            final Animation<double> animation,
            final Animation<double> secondaryAnimation,
          ) =>
              FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            fillColor: Colors.transparent,
            child: child,
          ),
          child: _SearchPopUp(
            key: ValueKey<ExtensionType>(popupPluginType),
            type: popupPluginType,
            currentPlugin: currentPlugin,
            onTypeTap: (final ExtensionType type) {
              setState(() {
                popupPluginType = type;
              });
            },
            onPluginTap: (final CurrentPlugin plugin) async {
              setState(() {
                currentPlugin = plugin;
              });

              final PreferencesSchema preferences = PreferencesBox.get();
              preferences.lastSelectedSearch =
                  preferences.lastSelectedSearch.copyWith(
                lastSelectedType: plugin.type,
                lastSelectedAnimePlugin: plugin.type == ExtensionType.anime
                    ? plugin.plugin.id
                    : null,
                lastSelectedMangaPlugin: plugin.type == ExtensionType.manga
                    ? plugin.plugin.id
                    : null,
              );
              await PreferencesBox.save(preferences);

              if (mounted) {
                this.setState(() {});
                Navigator.of(context).pop();

                if ((textController.text.isNotEmpty &&
                        results.state.hasEnded) ||
                    (args?.autoSearch ?? false)) {
                  if (args != null) {
                    args!.autoSearch = false;
                  }

                  await search();
                }
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.list),
          onPressed: () {
            selectPlugins(context);
          },
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: remToPx(1),
              horizontal: remToPx(1.25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Translator.t.search(),
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    labelText: currentPlugin != null
                        ? Translator.t
                            .searchInPlugin(currentPlugin!.plugin.name)
                        : Translator.t.selectPlugin(),
                    enabled: currentPlugin != null,
                  ),
                  onSubmitted: (final String terms) async {
                    await search();
                  },
                ),
                SizedBox(
                  height: remToPx(1.25),
                ),
                if (results.state.hasResolved && results.value!.isNotEmpty)
                  Column(
                    children: UiUtils.getGridded(
                      MediaQuery.of(context).size.width.toInt(),
                      results.value!
                          .map(
                            (final _SearchInfo x) => Card(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(4),
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    ParsedRouteInfo(
                                      x.pluginType.route(),
                                      x.pluginType.params(
                                        src: x.url,
                                        plugin: x.pluginId,
                                      ),
                                    ).toString(),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(remToPx(0.5)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        width: remToPx(4),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            remToPx(0.25),
                                          ),
                                          child: x.thumbnail != null
                                              ? FallbackableNetworkImage(
                                                  url: x.thumbnail!.url,
                                                  headers: x.thumbnail!.headers,
                                                  placeholder: Image.asset(
                                                    Assets.placeholderImage(
                                                      dark:
                                                          UiUtils.isDarkContext(
                                                        context,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Image.asset(
                                                  Assets.placeholderImage(
                                                    dark: UiUtils.isDarkContext(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                      SizedBox(width: remToPx(0.75)),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              x.title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .headline6
                                                    ?.fontSize,
                                              ),
                                            ),
                                            Text(
                                              x.pluginName,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    ?.fontSize,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  )
                else if (results.state.isResolving)
                  Padding(
                    padding: EdgeInsets.only(
                      top: remToPx(1.5),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                else
                  Center(
                    child: Text(
                      results.state.isWaiting
                          ? (args?.autoSearch ?? false
                              ? Translator.t.selectAPluginToGetResults()
                              : Translator.t.enterToSearch())
                          : results.state.hasResolved
                              ? Translator.t.noResultsFound()
                              : Translator.t.failedToGetResults(),
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .color!
                            .withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}

// ignore: avoid_private_typedef_functions
typedef _SearchPopUpOnPluginSelect = void Function(CurrentPlugin);

class _SearchPopUpTile extends StatelessWidget {
  const _SearchPopUpTile({
    required final this.onPluginTap,
    required final this.currentPlugin,
    required final this.plugin,
    final Key? key,
  }) : super(key: key);

  final _SearchPopUpOnPluginSelect onPluginTap;
  final CurrentPlugin? currentPlugin;
  final CurrentPlugin plugin;

  @override
  Widget build(final BuildContext context) => Material(
        type: MaterialType.transparency,
        child: RadioListTile<String>(
          title: Text(plugin.plugin.name),
          value: plugin.plugin.id,
          groupValue: currentPlugin?.plugin.id,
          activeColor: Theme.of(context).primaryColor,
          onChanged: (final String? val) async {
            if (val == plugin.plugin.id) {
              onPluginTap(plugin);
            }
          },
        ),
      );
}

class _SearchPopUp extends StatelessWidget {
  const _SearchPopUp({
    required final this.onPluginTap,
    required final this.onTypeTap,
    required final this.currentPlugin,
    required final this.type,
    final Key? key,
  }) : super(key: key);

  final _SearchPopUpOnPluginSelect onPluginTap;
  final void Function(ExtensionType) onTypeTap;
  final CurrentPlugin? currentPlugin;
  final ExtensionType type;

  @override
  Widget build(final BuildContext context) {
    Widget content = Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: remToPx(1),
          right: remToPx(1),
          top: remToPx(1.1),
          bottom: remToPx(0.5),
        ),
        child: Text(
          Translator.t.nothingWasFoundHere(),
          style: Theme.of(context).textTheme.bodyText2?.copyWith(
                color: Theme.of(context).textTheme.caption?.color,
              ),
        ),
      ),
    );

    switch (type) {
      case ExtensionType.anime:
        if (ExtensionsManager.animes.isNotEmpty) {
          content = Column(
            children: ExtensionsManager.animes.values
                .map(
                  (final AnimeExtractor x) => _SearchPopUpTile(
                    onPluginTap: onPluginTap,
                    currentPlugin: currentPlugin,
                    plugin: CurrentPlugin(
                      type: ExtensionType.anime,
                      plugin: x,
                    ),
                  ),
                )
                .toList(),
          );
        }
        break;

      case ExtensionType.manga:
        if (ExtensionsManager.mangas.isNotEmpty) {
          content = Column(
            children: ExtensionsManager.mangas.values
                .map(
                  (final MangaExtractor x) => _SearchPopUpTile(
                    onPluginTap: onPluginTap,
                    currentPlugin: currentPlugin,
                    plugin: CurrentPlugin(
                      type: ExtensionType.manga,
                      plugin: x,
                    ),
                  ),
                )
                .toList(),
          );
        }
        break;
    }

    final bool isLarge = MediaQuery.of(context).size.width > ResponsiveSizes.xs;
    final Widget typeSwitcher = Row(
      mainAxisSize: isLarge ? MainAxisSize.min : MainAxisSize.max,
      children: <ExtensionType>[
        ExtensionType.anime,
        ExtensionType.manga,
      ].map(
        (final ExtensionType x) {
          final bool isCurrent = x == type;

          final Widget child = Padding(
            padding: EdgeInsets.symmetric(
              horizontal: remToPx(0.1),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () {
                  onTypeTap(x);
                },
                borderRadius: BorderRadius.circular(4),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: remToPx(0.5),
                      vertical: remToPx(0.2),
                    ),
                    child: Text(
                      StringUtils.capitalize(x.type),
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: isCurrent ? Colors.white : null,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          );

          return isLarge
              ? child
              : Expanded(
                  child: child,
                );
        },
      ).toList(),
    );

    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets +
            EdgeInsets.symmetric(
              horizontal: remToPx(2),
              vertical: remToPx(1.2),
            ),
        child: Material(
          type: MaterialType.card,
          elevation: 24,
          borderRadius: BorderRadius.circular(4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: isLarge ? remToPx(0.8) : remToPx(0.6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: remToPx(1),
                    ),
                    child: isLarge
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                Translator.t.selectPlugin(),
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              typeSwitcher,
                            ],
                          )
                        : Column(
                            children: <Widget>[
                              Text(
                                Translator.t.selectPlugin(),
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              SizedBox(height: remToPx(0.5)),
                              typeSwitcher,
                            ],
                          ),
                  ),
                  SizedBox(
                    height: remToPx(0.3),
                  ),
                  content,
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: remToPx(0.7),
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: remToPx(0.6),
                              vertical: remToPx(0.3),
                            ),
                            child: Text(
                              Translator.t.close(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
