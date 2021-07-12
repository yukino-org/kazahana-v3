import 'package:flutter/material.dart';
import '../../core/utils.dart' as utils;
import '../../core/extractor/extractors.dart' as extractor;
import '../../core/extractor/animes/model.dart' as anime_model;
import '../../core/models/watch_page.dart' as watch_page;
import '../../core/models/player.dart' as player_model;
import '../../components/full_screen.dart';
import './players/player.dart';

class Page extends StatefulWidget {
  const Page({Key? key}) : super(key: key);

  @override
  State<Page> createState() => PageState();
}

class PageState extends State<Page> {
  utils.LoadState state = utils.LoadState.waiting;
  late player_model.Player player;

  Future<List<anime_model.EpisodeSource>> getInfo(
      watch_page.PageArguments args) async {
    return extractor.Extractors.anime[args.plugin]!.getSources(args.src);
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as watch_page.PageArguments;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
            future: getInfo(arguments),
            builder: (context, snapshot) {
              const loader = Center(
                child: CircularProgressIndicator(),
              );

              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData &&
                  snapshot.data is List<anime_model.EpisodeSource>) {
                final sources =
                    snapshot.data as List<anime_model.EpisodeSource>;

                if (sources.isEmpty) {
                  return const Center(
                    child: Text('No valid sources were found.'),
                  );
                }

                player = createPlayer(player_model.PlayerSource(
                  url: sources[0].url,
                  headers: sources[0].headers,
                ));

                return FutureBuilder(
                  future: player.initialize(),
                  builder: (conext, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return FullScreenWidget(
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: player.getWidget(),
                        ),
                      );
                    }

                    return loader;
                  },
                );
              }

              return loader;
            }),
      ),
    );
  }
}
