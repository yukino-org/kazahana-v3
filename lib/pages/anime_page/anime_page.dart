import 'package:flutter/material.dart';
import 'package:yukino_app/plugins/router.dart';
import '../../core/utils.dart' as utils;
import '../../core/extractor/extractors.dart' as extractor;
import '../../core/extractor/animes/model.dart' as anime_model;
import '../../core/models/anime_page.dart' as anime_page;
import '../../core/models/watch_page.dart' as watch_page;

class Page extends StatefulWidget {
  const Page({Key? key}) : super(key: key);

  @override
  State<Page> createState() => PageState();
}

class PageState extends State<Page> {
  utils.LoadState state = utils.LoadState.waiting;

  Future<anime_model.AnimeInfo> getInfo(anime_page.PageArguments args) async {
    return extractor.Extractors.anime[args.plugin]!.getInfo(args.src);
  }

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
    final arguments =
        ModalRoute.of(context)!.settings.arguments as anime_page.PageArguments;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: FutureBuilder(
            future: getInfo(arguments),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data is anime_model.AnimeInfo) {
                final info = snapshot.data as anime_model.AnimeInfo;

                return Container(
                  padding: EdgeInsets.only(
                    left: utils.remToPx(1.25),
                    right: utils.remToPx(1.25),
                    bottom: utils.remToPx(1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      heroBuilder(arguments, info),
                      SizedBox(
                        height: utils.remToPx(1.5),
                      ),
                      Text(
                        'Episodes',
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.bodyText2?.fontSize,
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
                                  borderRadius: BorderRadius.circular(4),
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
                                    Navigator.of(context)
                                        .pushNamed(RouteNames.watchPage,
                                            arguments: watch_page.PageArguments(
                                              src: x.url,
                                              plugin: arguments.plugin,
                                            ));
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }
}
