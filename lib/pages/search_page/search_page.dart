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
import '../../plugins/database/schemas/preferences/preferences.dart'
    as preferences_schema;
import '../../plugins/helpers/assets.dart';
import '../../plugins/helpers/stateful_holder.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/router.dart';
import '../../plugins/translator/translator.dart';

enum PluginTypes {
  anime,
  manga,
}

extension PluginRoutes on PluginTypes {
  String route() {
    switch (this) {
      case PluginTypes.anime:
        return RouteNames.animePage;

      case PluginTypes.manga:
        return RouteNames.mangaPage;
    }
  }

  Map<String, String> params({
    required final String plugin,
    required final String src,
  }) {
    switch (this) {
      case PluginTypes.anime:
        return anime_page.PageArguments(src: src, plugin: plugin).toJson();

      case PluginTypes.manga:
        return manga_page.PageArguments(src: src, plugin: plugin).toJson();
    }
  }
}

class CurrentPlugin {
  CurrentPlugin({
    required final this.type,
    required final this.plugin,
  });

  PluginTypes type;
  extensions.BaseExtractor plugin;

  @override
  String toString() => '${type.toString}-${plugin.name}';
}

class SearchInfo extends extensions.SearchInfo {
  SearchInfo({
    required final String title,
    required final String url,
    required final String locale,
    required final this.plugin,
    required final this.pluginType,
    final extensions.ImageInfo? thumbnail,
  }) : super(
          title: title,
          url: url,
          thumbnail: thumbnail,
          locale: locale,
        );

  final String plugin;
  final PluginTypes pluginType;
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
  LoadState state = LoadState.waiting;
  final preferences_schema.PreferencesSchema preferences =
      DataStore.preferences;

  List<String> animePlugins = ExtensionsManager.animes.keys.toList();
  List<String> mangaPlugins = ExtensionsManager.mangas.keys.toList();

  List<SearchInfo> results = <SearchInfo>[];

  late Widget placeholderImage;
  late CurrentPlugin currentPlugin;
  late search_page.PageArguments args;

  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    currentPlugin = CurrentPlugin(
      type: PluginTypes.anime,
      plugin: ExtensionsManager.animes[ExtensionsManager.animes.keys.first]!,
    );

    if (preferences.lastSelectedSearchType != null) {
      currentPlugin.type = PluginTypes.values.firstWhereOrNull(
            (final PluginTypes x) =>
                x.toString() == preferences.lastSelectedSearchType,
          ) ??
          currentPlugin.type;
    }

    if (preferences.lastSelectedSearchPlugin != null) {
      bool matched = false;

      for (final String x in animePlugins) {
        if (preferences.lastSelectedSearchPlugin == x) {
          currentPlugin.plugin = ExtensionsManager.animes[x]!;
          matched = true;
          break;
        }
      }

      if (!matched) {
        for (final String x in mangaPlugins) {
          if (preferences.lastSelectedSearchPlugin == x) {
            currentPlugin.plugin = ExtensionsManager.mangas[x]!;
            matched = true;
            break;
          }
        }
      }
    }

    Future<void>.delayed(Duration.zero, () async {
      if (mounted) {
        placeholderImage = Image.asset(
          Assets.placeholderImage(
            dark: isDarkContext(
              context,
            ),
          ),
        );

        args = search_page.PageArguments.fromJson(
          ParsedRouteInfo.fromSettings(ModalRoute.of(context)!.settings).params,
        );

        if (args.terms != null) {
          setState(() {
            textController.text = args.terms!;
          });

          if (args.autoSearch == true) {
            final List<SearchInfo> res = await search();
            if (mounted) {
              setState(() {
                results = res;
                state = LoadState.resolved;
              });
            }
          }
        }
      }
    });
  }

  Future<List<SearchInfo>> search() async {
    final List<SearchInfo> results = <SearchInfo>[];
    final List<extensions.SearchInfo> searches =
        await currentPlugin.plugin.search(
      textController.text,
      Translator.t.code.code,
    );

    results.addAll(
      searches.map(
        (final extensions.SearchInfo x) => SearchInfo(
          title: x.title,
          url: x.url,
          thumbnail: x.thumbnail,
          locale: x.locale,
          plugin: currentPlugin.plugin.name,
          pluginType: currentPlugin.type,
        ),
      ),
    );

    return results;
  }

  Widget getPluginWidget(final CurrentPlugin plugin) => Material(
        type: MaterialType.transparency,
        child: RadioListTile<String>(
          title: Text(plugin.plugin.name),
          value: plugin.toString(),
          groupValue: currentPlugin.toString(),
          activeColor: Theme.of(context).primaryColor,
          onChanged: (final String? val) async {
            if (val != null) {
              setState(() {
                currentPlugin = plugin;
                preferences.lastSelectedSearchType = plugin.type.toString();
                preferences.lastSelectedSearchPlugin = plugin.plugin.name;
                Navigator.of(context).pop();
              });

              await preferences.save();
            }
          },
        ),
      );

  Future<void> selectPlugins(final BuildContext context) async {
    final List<Widget> left = <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: remToPx(1),
        ),
        child: Text(
          Translator.t.anime(),
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyText1?.fontSize,
            color:
                Theme.of(context).textTheme.bodyText1?.color?.withOpacity(0.7),
          ),
        ),
      ),
      ...animePlugins
          .map(
            (final String x) => getPluginWidget(
              CurrentPlugin(
                type: PluginTypes.anime,
                plugin: ExtensionsManager.animes[x]!,
              ),
            ),
          )
          .toList(),
    ];

    final List<Widget> right = <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: remToPx(1),
        ),
        child: Text(
          Translator.t.manga(),
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyText1?.fontSize,
            color:
                Theme.of(context).textTheme.bodyText1?.color?.withOpacity(0.7),
          ),
        ),
      ),
      ...mangaPlugins
          .map(
            (final String x) => getPluginWidget(
              CurrentPlugin(
                type: PluginTypes.manga,
                plugin: ExtensionsManager.mangas[x]!,
              ),
            ),
          )
          .toList(),
    ];

    final List<Widget> plugins =
        MediaQuery.of(context).size.width > ResponsiveSizes.md
            ? <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: left,
                      ),
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: right,
                      ),
                    ),
                  ],
                )
              ]
            : <Widget>[
                ...left,
                ...right,
              ];

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (
        final BuildContext context,
        final Animation<double> a1,
        final Animation<double> a2,
      ) =>
          Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        child: StatefulBuilder(
          builder: (final BuildContext context, final StateSetter setState) =>
              SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: remToPx(0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: remToPx(1),
                  ),
                  child: Text(
                    Translator.t.selectPlugin(),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                SizedBox(
                  height: remToPx(0.3),
                ),
                ...plugins,
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: remToPx(0.7),
                    ),
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
              ],
            ),
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
                    labelText:
                        Translator.t.searchInPlugin(currentPlugin.plugin.name),
                  ),
                  onSubmitted: (final String terms) async {
                    setState(() {
                      state = LoadState.resolving;
                    });

                    try {
                      final List<SearchInfo> res = await search();
                      setState(() {
                        results = res;
                        state = LoadState.resolved;
                      });
                    } catch (e) {
                      setState(() {
                        state = LoadState.failed;
                      });
                    }
                  },
                ),
                SizedBox(
                  height: remToPx(1.25),
                ),
                Visibility(
                  visible: (state == LoadState.resolved && results.isEmpty) ||
                      state == LoadState.waiting ||
                      state == LoadState.failed,
                  child: Align(
                    child: Text(
                      state == LoadState.waiting
                          ? Translator.t.enterToSearch()
                          : state == LoadState.resolved
                              ? Translator.t.noResultsFound()
                              : state == LoadState.failed
                                  ? Translator.t.failedToGetResults()
                                  : '',
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .color!
                            .withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: state == LoadState.resolving,
                  child: Container(
                    margin: EdgeInsets.only(
                      top: remToPx(1.5),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
                Visibility(
                  visible: state == LoadState.resolved && results.isNotEmpty,
                  child: Column(
                    children: getGridded(
                      MediaQuery.of(context).size,
                      results
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
                                        plugin: x.plugin,
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
                                                  placeholder: placeholderImage,
                                                )
                                              : placeholderImage,
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
                                              x.plugin,
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
                  ),
                )
              ],
            ),
          ),
        ),
      );
}
