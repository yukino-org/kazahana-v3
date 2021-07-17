import 'package:flutter/material.dart';
import '../../core/utils.dart' as utils;
import '../../core/extractor/extractors.dart' as extractor;
import '../../core/extractor/animes/model.dart' as anime_model;
import '../../core/models/anime_page.dart' as anime_page;
import '../../plugins/router.dart';
import '../../plugins/translator/translator.dart';

class Page extends StatefulWidget {
  const Page({Key? key}) : super(key: key);

  @override
  State<Page> createState() => PageState();
}

class SearchInfo extends anime_model.SearchInfo {
  String plugin;

  SearchInfo({
    required String title,
    required String url,
    String? thumbnail,
    required this.plugin,
  }) : super(title: title, url: url, thumbnail: thumbnail);
}

class PageState extends State<Page> {
  utils.LoadState state = utils.LoadState.waiting;
  List<String> allPlugins = extractor.Extractors.anime.keys.toList();
  String currentPlugin = extractor.Extractors.anime.keys.first;
  List<SearchInfo> results = [];

  Future<List<SearchInfo>> search(String terms) async {
    List<SearchInfo> results = [];
    final inst = extractor.Extractors.anime[currentPlugin];
    if (inst != null) {
      final infos = await inst.search(terms);
      results.addAll(
        infos.map(
          (x) => SearchInfo(
            title: x.title,
            url: x.url,
            thumbnail: x.thumbnail,
            plugin: currentPlugin,
          ),
        ),
      );
    }
    return results;
  }

  void selectPlugins(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            child: SizedBox(
              height: utils.remToPx(20),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: utils.remToPx(0.8),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: utils.remToPx(1),
                        ),
                        child: Text(
                          Translator.t.selectPlugin(),
                          style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.headline6?.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: utils.remToPx(0.3),
                      ),
                      ...allPlugins
                          .map(
                            (x) => Material(
                              type: MaterialType.transparency,
                              child: RadioListTile(
                                  title: Text(x),
                                  value: x,
                                  groupValue: currentPlugin,
                                  activeColor: Theme.of(context).primaryColor,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val != null) {
                                        currentPlugin = x;
                                      }
                                    });
                                  }),
                            ),
                          )
                          .toList(),
                    ]),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.list),
        onPressed: () {
          selectPlugins(context);
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: utils.remToPx(1),
              horizontal: utils.remToPx(1.25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    labelText: Translator.t.searchInPlugin(currentPlugin),
                  ),
                  onSubmitted: (terms) async {
                    setState(() {
                      state = utils.LoadState.resolving;
                    });

                    try {
                      final res = await search(terms);
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
                  child: Align(
                    alignment: Alignment.center,
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
                  visible:
                      (state == utils.LoadState.resolved && results.isEmpty) ||
                          state == utils.LoadState.waiting ||
                          state == utils.LoadState.failed,
                ),
                Visibility(
                  child: Container(
                    margin: EdgeInsets.only(
                      top: utils.remToPx(1.5),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  visible: state == utils.LoadState.resolving,
                ),
                Visibility(
                  child: Column(
                    children: results
                        .map(
                          (x) => Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: EdgeInsets.all(utils.remToPx(0.5)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
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
                                                        context)),
                                              ),
                                      ),
                                    ),
                                    SizedBox(width: utils.remToPx(0.75)),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
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
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  RouteNames.animePage,
                                  arguments: anime_page.PageArguments(
                                    src: x.url,
                                    plugin: x.plugin,
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  visible:
                      state == utils.LoadState.resolved && results.isNotEmpty,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
