import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../../components/network_image_fallback.dart';
import '../../core/extractor/extractors.dart' as extractor;
import '../../core/extractor/model.dart' as base_model;
import '../../core/models/anime_page.dart' as anime_page;
import '../../core/models/manga_page.dart' as manga_page;
import '../../plugins/helpers/assets.dart';
import '../../plugins/helpers/stateful_holder.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/helpers/utils/list.dart';
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

  final PluginTypes type;
  final base_model.BaseExtractorPlugin<base_model.BaseSearchInfo> plugin;

  @override
  String toString() => '${type.toString}-${plugin.name}';
}

class SearchInfo extends base_model.BaseSearchInfo {
  SearchInfo({
    required final String title,
    required final String url,
    required final this.plugin,
    required final this.pluginType,
    final base_model.ImageInfo? thumbnail,
  }) : super(
          title: title,
          url: url,
          thumbnail: thumbnail,
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
  List<String> animePlugins = extractor.Extractors.anime.keys.toList();
  List<String> mangaPlugins = extractor.Extractors.manga.keys.toList();
  CurrentPlugin currentPlugin = CurrentPlugin(
    type: PluginTypes.anime,
    plugin: extractor.Extractors.anime[extractor.Extractors.anime.keys.first]!,
  );
  List<SearchInfo> results = <SearchInfo>[];

  late Widget placeholderImage;

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(Duration.zero, () {
      placeholderImage = Image.asset(
        Assets.placeholderImage(
          dark: isDarkContext(
            context,
          ),
        ),
      );
    });
  }

  Future<List<SearchInfo>> search(final String terms) async {
    final List<SearchInfo> results = <SearchInfo>[];
    final List<base_model.BaseSearchInfo> searches =
        await currentPlugin.plugin.search(
      terms,
      locale: Translator.t.code,
    );

    results.addAll(
      searches.map(
        (final base_model.BaseSearchInfo x) => SearchInfo(
          title: x.title,
          url: x.url,
          thumbnail: x.thumbnail,
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
          onChanged: (final String? val) {
            setState(() {
              if (val != null) {
                currentPlugin = plugin;
                Navigator.of(context).pop();
              }
            });
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
                plugin: extractor.Extractors.anime[x]!,
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
                plugin: extractor.Extractors.manga[x]!,
              ),
            ),
          )
          .toList(),
    ];

    final List<Widget> plugins =
        Platform.isLinux || Platform.isMacOS || Platform.isWindows
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

    await showDialog(
      context: context,
      builder: (final BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
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
              const SizedBox(
                height: 6,
              ),
              ...plugins,
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
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
    );
  }

  List<Widget> getGridded(
    final BuildContext context,
    final List<Widget> children,
  ) {
    if (MediaQuery.of(context).size.width > ResponsiveSizes.lg) {
      const Widget filler = Expanded(
        child: SizedBox.shrink(),
      );

      return ListUtils.chunk<Widget>(children, 2, filler)
          .map(
            (final List<Widget> x) => Row(
              children: x.map((final Widget x) => Expanded(child: x)).toList(),
            ),
          )
          .toList();
    }

    return children;
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
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: remToPx(1),
              horizontal: remToPx(1.25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Translator.t.search(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: Theme.of(context).textTheme.headline6?.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText:
                        Translator.t.searchInPlugin(currentPlugin.plugin.name),
                  ),
                  onSubmitted: (final String terms) async {
                    setState(() {
                      state = LoadState.resolving;
                    });

                    try {
                      final List<SearchInfo> res = await search(terms);
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
                      context,
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
