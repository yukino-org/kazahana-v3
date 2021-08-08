import 'package:flutter/material.dart';
import '../../core/extractor/extractors.dart' as extractor;
import '../../core/extractor/model.dart' as base_model;
import '../../core/models/anime_page.dart' as anime_page;
import '../../core/models/manga_page.dart' as manga_page;
import '../../core/utils.dart' as utils;
import '../../plugins/router.dart';
import '../../plugins/translator/translator.dart';

enum PluginTypes { anime, manga }

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

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(
          key: key,
        );

  @override
  State<Page> createState() => PageState();
}

class SearchInfo extends base_model.BaseSearchInfo {
  SearchInfo({
    required final String title,
    required final String url,
    required final this.plugin,
    required final this.pluginType,
    final String? thumbnail,
  }) : super(
          title: title,
          url: url,
          thumbnail: thumbnail,
        );

  final String plugin;
  final PluginTypes pluginType;
}

class PageState extends State<Page> {
  utils.LoadState state = utils.LoadState.waiting;
  List<String> animePlugins = extractor.Extractors.anime.keys.toList();
  List<String> mangaPlugins = extractor.Extractors.manga.keys.toList();
  CurrentPlugin currentPlugin = CurrentPlugin(
    type: PluginTypes.anime,
    plugin: extractor.Extractors.anime[extractor.Extractors.anime.keys.first]!,
  );
  List<SearchInfo> results = <SearchInfo>[];

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
                  horizontal: utils.remToPx(1),
                ),
                child: Text(
                  Translator.t.selectPlugin(),
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: utils.remToPx(1),
                ),
                child: Text(
                  Translator.t.anime(),
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyText1?.fontSize,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.color
                        ?.withOpacity(0.7),
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
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: utils.remToPx(1),
                ),
                child: Text(
                  Translator.t.manga(),
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyText1?.fontSize,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.color
                        ?.withOpacity(0.7),
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
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: utils.remToPx(0.6),
                        vertical: utils.remToPx(0.3),
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
              vertical: utils.remToPx(1),
              horizontal: utils.remToPx(1.25),
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
                      state = utils.LoadState.resolving;
                    });

                    try {
                      final List<SearchInfo> res = await search(terms);
                      setState(() {
                        results = res;
                        state = utils.LoadState.resolved;
                      });
                    } catch (e) {
                      setState(() {
                        state = utils.LoadState.failed;
                      });
                    }
                  },
                ),
                SizedBox(
                  height: utils.remToPx(1.25),
                ),
                Visibility(
                  visible:
                      (state == utils.LoadState.resolved && results.isEmpty) ||
                          state == utils.LoadState.waiting ||
                          state == utils.LoadState.failed,
                  child: Align(
                    child: Text(
                      state == utils.LoadState.waiting
                          ? Translator.t.enterToSearch()
                          : state == utils.LoadState.resolved
                              ? Translator.t.noResultsFound()
                              : state == utils.LoadState.failed
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
                  visible: state == utils.LoadState.resolving,
                  child: Container(
                    margin: EdgeInsets.only(
                      top: utils.remToPx(1.5),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
                Visibility(
                  visible:
                      state == utils.LoadState.resolved && results.isNotEmpty,
                  child: Column(
                    children: results
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
                                padding: EdgeInsets.all(utils.remToPx(0.5)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      width: utils.remToPx(4),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          utils.remToPx(0.25),
                                        ),
                                        child: x.thumbnail != null
                                            ? Image.network(x.thumbnail!)
                                            : Image.asset(
                                                utils.Assets.placeholderImage(
                                                  utils.Fns.isDarkContext(
                                                    context,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                    SizedBox(width: utils.remToPx(0.75)),
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
                )
              ],
            ),
          ),
        ),
      );
}
