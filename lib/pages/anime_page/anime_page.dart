import 'package:flutter/material.dart';
import '../../core/utils.dart' as utils;
import '../../core/extractor/extractors.dart' as extractor;
import '../../core/extractor/animes/model.dart' as anime_model;
import '../../core/models/anime_page.dart' as anime_page;

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
      final left = info.thumbnail != null
          ? Image.network(info.thumbnail!)
          : const SizedBox.shrink();

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
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: utils.remToPx(1),
            horizontal: utils.remToPx(1.25),
          ),
          child: FutureBuilder(
              future: getInfo(arguments),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data is anime_model.AnimeInfo) {
                  final info = snapshot.data as anime_model.AnimeInfo;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      heroBuilder(arguments, info),
                      SizedBox(
                        height: utils.remToPx(1),
                      ),
                      Text(
                        'Episodes',
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.bodyText2?.fontSize,
                        ),
                      ),
                    ],
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              }),
        ),
      ),
    );
  }
}
