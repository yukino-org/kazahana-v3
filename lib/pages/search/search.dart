import 'package:flutter/material.dart';
import 'package:yukino_app/plugins/routes.dart';
import '../../core/utils.dart' as utils;
import '../../core/extractor/extractors.dart' as extractor;
import '../../core/extractor/animes/model.dart' as anime_model;
import '../../core/models/anime_page.dart' as anime_page;

class Page extends StatefulWidget {
  const Page({Key? key}) : super(key: key);

  @override
  State<Page> createState() => PageState();
}

class SearchInfo extends anime_model.SearchInfo {
  String plugin;

  SearchInfo(
      {required String title,
      required String url,
      String? thumbnail,
      required this.plugin})
      : super(title: title, url: url, thumbnail: thumbnail);
}

class PageState extends State<Page> {
  utils.LoadState state = utils.LoadState.waiting;
  List<String> plugins = ['TwistMoe'];
  List<SearchInfo> results = [];

  Future<List<SearchInfo>> search(String terms, List<String> plugins) async {
    List<SearchInfo> results = [];
    for (final plugin in plugins) {
      final inst = extractor.Extractors.anime[plugin];
      if (inst != null) {
        final infos = await inst.search(terms);
        results.addAll(infos.map((x) => SearchInfo(
            title: x.title,
            url: x.url,
            thumbnail: x.thumbnail,
            plugin: plugin)));
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  "Search",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: Theme.of(context).textTheme.headline6?.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  onSubmitted: (terms) async {
                    setState(() {
                      state = utils.LoadState.resolving;
                    });

                    try {
                      final res = await search(terms, plugins);
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
                          ? 'Enter something to search!'
                          : state == utils.LoadState.resolved
                              ? 'No results were found.'
                              : state == utils.LoadState.failed
                                  ? 'Failed to fetch results.'
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
                  child: const Center(child: CircularProgressIndicator()),
                  visible: state == utils.LoadState.resolving,
                ),
                Visibility(
                  child: Column(
                    children: results
                        .map(
                          (x) => Card(
                            child: InkWell(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: utils.remToPx(0.5),
                                  vertical: utils.remToPx(0.25),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Visibility(
                                      child: Expanded(
                                        flex: 1,
                                        child: x.thumbnail != null
                                            ? Image.network(x.thumbnail!)
                                            : const Text(''),
                                      ),
                                      visible: x.thumbnail != null,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
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
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                RouteManager.navigationKey.currentState
                                    ?.pushNamed(
                                        RouteManager
                                            .allRoutes[RouteNames.animePage]!
                                            .route,
                                        arguments: anime_page.PageArguments(
                                          src: x.url,
                                          plugin: x.plugin,
                                        ));
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
