import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import '../../core/utils.dart' as utils;
import '../../core/extractor/extractors.dart' as extractor;
import '../../core/extractor/animes/model.dart' as anime_model;
import '../../core/models/anime_page.dart' as anime_page;
import '../../core/models/player.dart' as player_model;
import '../../plugins/router.dart';
import '../../plugins/state.dart' show AppState;
import '../../plugins/translator/translator.dart';
import '../../components/player/player.dart';
import '../../components/full_screen.dart';
import '../../components/oriented_widget.dart';

enum Pages { home, player }

class Page extends StatefulWidget {
  const Page({final Key? key}) : super(key: key);

  @override
  State<Page> createState() => PageState();
}

class PageState extends State<Page> {
  late PageController controller;
  anime_model.EpisodeInfo? episode;
  player_model.Player? player;
  late int currentIndex;

  @override
  void initState() {
    super.initState();

    currentIndex = Pages.home.index;
    controller = PageController(
      initialPage: currentIndex,
      keepPage: true,
    );
  }

  void goToPage(final Pages page) {
    controller.animateToPage(
      page.index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Future<anime_model.AnimeInfo> getInfo(final anime_page.PageArguments args) =>
      extractor.Extractors.anime[args.plugin]!.getInfo(
        args.src,
        locale: Translator.t.code,
      );

  Future<List<anime_model.EpisodeSource>> getSources(
    String plugin,
    anime_model.EpisodeInfo episode,
  ) =>
      extractor.Extractors.anime[plugin]!.getSources(episode);

  Widget heroBuilder(
      anime_page.PageArguments args, anime_model.AnimeInfo info) {
    return LayoutBuilder(builder: (context, constraints) {
      final image = info.thumbnail != null
          ? Image.network(
              info.thumbnail!,
              width: utils.remToPx(7),
            )
          : Image.asset(
              utils.Assets.placeholderImage(
                utils.Fns.isDarkContext(context),
              ),
              width: utils.remToPx(7),
            );

      final left = ClipRRect(
        borderRadius: BorderRadius.circular(utils.remToPx(0.5)),
        child: image,
      );

      final right = Column(
        children: [
          Text(
            info.title,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.headline4?.fontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            args.plugin,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: Theme.of(context).textTheme.headline6?.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );

      if (constraints.maxWidth > utils.ResponsiveSizes.md) {
        return Row(
          children: [
            left,
            right,
          ],
        );
      } else {
        return Column(
          children: [
            left,
            SizedBox(
              height: utils.remToPx(1),
            ),
            right,
          ],
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = anime_page.PageArguments.fromJson(
      RouteManager.parseRoute(ModalRoute.of(context)!.settings.name!).params,
    );

    const loader = Center(
      child: CircularProgressIndicator(),
    );

    return WillPopScope(
        child: PageView(
          onPageChanged: (page) {
            setState(() {
              currentIndex = page;
            });
          },
          controller: controller,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              body: FutureBuilder(
                  future: getInfo(args),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData &&
                        snapshot.data is anime_model.AnimeInfo) {
                      final info = snapshot.data as anime_model.AnimeInfo;

                      return SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.only(
                            left: utils.remToPx(1.25),
                            right: utils.remToPx(1.25),
                            bottom: utils.remToPx(1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              heroBuilder(args, info),
                              SizedBox(
                                height: utils.remToPx(1.5),
                              ),
                              Text(
                                Translator.t.episodes(),
                                style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      ?.fontSize,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      ?.color
                                      ?.withOpacity(0.7),
                                ),
                              ),
                              Wrap(
                                children: info.episodes
                                    .map(
                                      (x) => Card(
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: utils.remToPx(0.9),
                                              vertical: utils.remToPx(0.1),
                                            ),
                                            child: Text(
                                              x.episode,
                                              style: TextStyle(
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .headline6
                                                    ?.fontSize,
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              player = null;
                                              episode = x;
                                            });

                                            goToPage(Pages.player);
                                          },
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return loader;
                  }),
            ),
            episode != null
                ? FutureBuilder(
                    future: getSources(args.plugin, episode!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData &&
                          snapshot.data is List<anime_model.EpisodeSource>) {
                        final sources =
                            snapshot.data as List<anime_model.EpisodeSource>;

                        if (sources.isEmpty) {
                          return Center(
                            child: Text(Translator.t.noValidSources()),
                          );
                        }

                        player = createPlayer(player_model.PlayerSource(
                          url: sources[0].url,
                          headers: sources[0].headers,
                        ));

                        return FutureBuilder(
                          future: player!.initialize(),
                          builder: (conext, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return FullScreenWidget(
                                child: OrientedWidget(
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: player!.getWidget(),
                                  ),
                                  orientation: AppState.settings.current
                                          .fullscreenVideoPlayer
                                      ? [
                                          DeviceOrientation.landscapeLeft,
                                          DeviceOrientation.landscapeRight,
                                        ]
                                      : [],
                                ),
                              );
                            }

                            return loader;
                          },
                        );
                      }

                      return loader;
                    },
                  )
                : Center(
                    child: Text(Translator.t.prohibitedPage()),
                  ),
          ],
        ),
        onWillPop: () async {
          if (currentIndex != Pages.home.index) {
            player = null;
            episode = null;
            goToPage(Pages.home);
            return false;
          }

          Navigator.of(context).pop();
          return true;
        });
  }
}
