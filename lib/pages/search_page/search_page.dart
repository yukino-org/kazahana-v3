import 'package:animations/animations.dart';
import 'package:collection/collection.dart';
import 'package:extensions/extensions.dart' as extensions;
import 'package:flutter/material.dart';
import '../../components/network_image_fallback.dart';
import '../../core/extensions.dart';
import '../../core/models/languages.dart';
import '../../core/models/page_args/anime_page.dart' as anime_page;
import '../../core/models/page_args/manga_page.dart' as manga_page;
import '../../core/models/page_args/search_page.dart' as search_page;
import '../../plugins/database/database.dart';
import '../../plugins/helpers/assets.dart';
import '../../plugins/helpers/stateful_holder.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/helpers/utils/string.dart';
import '../../plugins/router.dart';
import '../../plugins/translator/translator.dart';

extension PluginRoutes on extensions.ExtensionType {
  String route() {
    switch (this) {
      case extensions.ExtensionType.anime:
        return RouteNames.animePage;

      case extensions.ExtensionType.manga:
        return RouteNames.mangaPage;
    }
  }

  Map<String, String> params({
    required final String plugin,
    required final String src,
  }) {
    switch (this) {
      case extensions.ExtensionType.anime:
        return anime_page.PageArguments(src: src, plugin: plugin).toJson();

      case extensions.ExtensionType.manga:
        return manga_page.PageArguments(src: src, plugin: plugin).toJson();
    }
  }
}

class CurrentPlugin {
  CurrentPlugin({
    required final this.type,
    required final this.plugin,
  });

  extensions.ExtensionType type;
  extensions.BaseExtractor plugin;
}

class SearchInfo extends extensions.SearchInfo {
  SearchInfo({
    required final String title,
    required final String url,
    required final String locale,
    required final this.pluginName,
    required final this.pluginId,
    required final this.pluginType,
    final extensions.ImageInfo? thumbnail,
  }) : super(
          title: title,
          url: url,
          thumbnail: thumbnail,
          locale: locale,
        );

  final String pluginName;
  final String pluginId;
  final extensions.ExtensionType pluginType;
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
  List<String> animePlugins = ExtensionsManager.animes.keys.toList();
  List<String> mangaPlugins = ExtensionsManager.mangas.keys.toList();

  CurrentPlugin? currentPlugin;
  StatefulHolder<List<SearchInfo>?> results =
      StatefulHolder<List<SearchInfo>?>(null);

  extensions.ExtensionType popupPluginType = extensions.ExtensionType.anime;
  search_page.PageArguments? args;

  final TextEditingController textController = TextEditingController();
  final Duration animationDuration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();

    _setCurrentPreferredPlugin();

    Future<void>.delayed(Duration.zero, () async {
      if (mounted) {
        args = search_page.PageArguments.fromJson(
          ParsedRouteInfo.fromSettings(ModalRoute.of(context)!.settings).params,
        );

        if (args?.pluginType != null) {
          setState(() {
            _setCurrentPreferredPlugin(args!.pluginType!.type);
          });
        }

        if (args?.terms?.isNotEmpty ?? false) {
          setState(() {
            textController.text = args!.terms!;
          });

          if (currentPlugin != null && (args?.autoSearch ?? false)) {
            args!.autoSearch = false;
            await search();
          }
        }
      }
    });
  }

  void _setCurrentPreferredPlugin([final String? _pluginType]) {
    final String? pluginType =
        _pluginType ?? DataStore.preferences.lastSelectedSearchType;

    if (DataStore.preferences.lastSelectedSearchType != null &&
        pluginType != null) {
      final extensions.ExtensionType? type =
          extensions.ExtensionType.values.firstWhereOrNull(
        (final extensions.ExtensionType x) => x.type == pluginType,
      );

      if (type != null &&
          DataStore.preferences.lastSelectedSearchPlugins != null) {
        extensions.BaseExtractor? ext;

        switch (type) {
          case extensions.ExtensionType.anime:
            ext = ExtensionsManager.animes[
                DataStore.preferences.lastSelectedSearchPlugins![pluginType]];
            break;

          case extensions.ExtensionType.manga:
            ext = ExtensionsManager.mangas[
                DataStore.preferences.lastSelectedSearchPlugins![pluginType]];
            break;
        }

        if (ext != null) {
          currentPlugin = CurrentPlugin(type: type, plugin: ext);
          popupPluginType = type;
        }
      }
    }
  }

  Future<void> search() async {
    if (currentPlugin != null && mounted) {
      setState(() {
        results.resolving(null);
      });

      try {
        final List<extensions.SearchInfo> searches =
            await currentPlugin!.plugin.search(
          textController.text,
          Translator.t.code.code,
        );

        if (mounted) {
          setState(() {
            results.resolve(
              searches
                  .map(
                    (final extensions.SearchInfo x) => SearchInfo(
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

  Widget getPluginWidget(final CurrentPlugin plugin) => Material(
        type: MaterialType.transparency,
        child: RadioListTile<String>(
          title: Text(plugin.plugin.name),
          value: plugin.plugin.id,
          groupValue: currentPlugin?.plugin.id,
          activeColor: Theme.of(context).primaryColor,
          onChanged: (final String? val) async {
            if (val != null) {
              setState(() {
                currentPlugin = plugin;
              });

              DataStore.preferences.lastSelectedSearchType = plugin.type.type;
              DataStore.preferences
                  .setLastSelectedSearchPlugin(plugin.type, plugin.plugin);

              await DataStore.preferences.save();

              if (mounted) {
                Navigator.of(context).pop();

                if (args?.autoSearch ?? false) {
                  args!.autoSearch = false;
                  await search();
                }
              }
            }
          },
        ),
      );

  Widget getPluginPage(
    final extensions.ExtensionType type,
    final StateSetter setState,
  ) {
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
      case extensions.ExtensionType.anime:
        if (ExtensionsManager.animes.isNotEmpty) {
          content = Column(
            children: ExtensionsManager.animes.values
                .map(
                  (final extensions.AnimeExtractor x) => getPluginWidget(
                    CurrentPlugin(
                      type: extensions.ExtensionType.anime,
                      plugin: x,
                    ),
                  ),
                )
                .toList(),
          );
        }
        break;

      case extensions.ExtensionType.manga:
        if (ExtensionsManager.mangas.isNotEmpty) {
          content = Column(
            children: ExtensionsManager.mangas.values
                .map(
                  (final extensions.MangaExtractor x) => getPluginWidget(
                    CurrentPlugin(
                      type: extensions.ExtensionType.manga,
                      plugin: x,
                    ),
                  ),
                )
                .toList(),
          );
        }
        break;
    }

    return SafeArea(
      key: ValueKey<extensions.ExtensionType>(type),
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
                vertical: MediaQuery.of(context).size.width > ResponsiveSizes.md
                    ? remToPx(0.8)
                    : remToPx(0.6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: remToPx(1),
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(
                          Translator.t.selectPlugin(),
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        const Expanded(
                          child: SizedBox.shrink(),
                        ),
                        ...<extensions.ExtensionType>[
                          extensions.ExtensionType.anime,
                          extensions.ExtensionType.manga,
                        ].map(
                          (final extensions.ExtensionType x) {
                            final bool isCurrent = x == popupPluginType;

                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: remToPx(0.1),
                              ),
                              child: Material(
                                type: MaterialType.transparency,
                                child: InkWell(
                                  mouseCursor: SystemMouseCursors.click,
                                  onTap: () {
                                    setState(() {
                                      popupPluginType = x;
                                    });
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .copyWith(
                                              color: isCurrent
                                                  ? Colors.white
                                                  : null,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
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
          duration: animationDuration,
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
          child: getPluginPage(popupPluginType, setState),
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
                if (results.hasResolved && results.value!.isNotEmpty)
                  Column(
                    children: getGridded(
                      MediaQuery.of(context).size.width.toInt(),
                      results.value!
                          .map(
                            (final SearchInfo x) => Card(
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
                                                      dark: isDarkContext(
                                                        context,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Image.asset(
                                                  Assets.placeholderImage(
                                                    dark: isDarkContext(
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
                else if (results.isResolving)
                  Padding(
                    padding: EdgeInsets.only(
                      top: remToPx(1.5),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                else
                  Center(
                    child: Text(
                      results.isWaiting
                          ? (args?.autoSearch ?? false
                              ? Translator.t.selectAPluginToGetResults()
                              : Translator.t.enterToSearch())
                          : results.hasResolved
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
