import 'package:flutter/material.dart';
import 'package:tenka/tenka.dart';
import 'package:utilx/utils.dart';
import '../../../../core/exports.dart';

class ResultsGrid extends StatelessWidget {
  const ResultsGrid({
    required this.type,
    required this.results,
    final Key? key,
  }) : super(key: key);

  final TenkaType type;
  final List<dynamic> results;

  Widget buildChip({
    required final BuildContext context,
    required final Widget child,
    final Widget? icon,
  }) =>
      DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomAppBarColor,
          borderRadius: BorderRadius.circular(rem(0.2)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: rem(0.2)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                IconTheme(
                  data: Theme.of(context).iconTheme.copyWith(size: rem(0.5)),
                  child: icon,
                ),
                SizedBox(width: rem(0.15)),
              ],
              child,
            ],
          ),
        ),
      );

  Widget buildTile(
    final dynamic result, {
    required final BuildContext context,
  }) {
    final String title;
    final String thumbnail;
    final String subtype;
    final String? rating;
    final int? ranking;

    switch (type) {
      case TenkaType.anime:
        final KitsuAnime anime = result as KitsuAnime;
        title = anime.canonicalTitle;
        thumbnail = anime.posterImageOriginal;
        subtype = anime.subtype.titleCase;
        rating = anime.averageRating;
        ranking = anime.popularityRank;
        break;

      case TenkaType.manga:
        final KitsuManga manga = result as KitsuManga;
        title = manga.canonicalTitle;
        thumbnail = manga.posterImageOriginal;
        subtype = manga.subtype.titleCase;
        rating = manga.averageRating;
        ranking = manga.popularityRank;
        break;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: rem(1)),
      child: InkWell(
        borderRadius: BorderRadius.circular(rem(0.25)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(rem(0.25)),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Image.network(
                        thumbnail,
                        fit: BoxFit.cover,
                        loadingBuilder: (
                          final _,
                          final Widget child,
                          final ImageChunkEvent? loadingProgress,
                        ) {
                          if (loadingProgress == null) return child;

                          return Container(
                            color: Theme.of(context).bottomAppBarColor,
                          );
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.all(rem(0.25)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: ListUtils.insertBetween(
                            <Widget>[
                              if (ranking != null)
                                buildChip(
                                  context: context,
                                  icon: Icon(
                                    Icons.tag,
                                    color: ColorPalettes.blue.c500,
                                  ),
                                  child: Text(ranking.toString()),
                                ),
                              if (rating != null)
                                buildChip(
                                  context: context,
                                  icon: Icon(
                                    Icons.star,
                                    color: ColorPalettes.yellow.c500,
                                  ),
                                  child: Text(rating),
                                ),
                              buildChip(context: context, child: Text(subtype)),
                            ],
                            SizedBox(height: rem(0.2)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: rem(0.25)),
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  List<Widget> buildTiles({
    required final BuildContext context,
  }) =>
      results.map((final dynamic x) => buildTile(x, context: context)).toList();

  Widget buildGridRow(final List<Widget> children) => Row(
        children: ListUtils.insertBetween(
          children.map((final Widget x) => Expanded(child: x)).toList(),
          SizedBox(width: rem(1)),
        ),
      );

  List<Widget> buildGridded({
    required final BuildContext context,
  }) =>
      ListUtils.chunk(buildTiles(context: context), 2)
          .map(buildGridRow)
          .toList();

  @override
  Widget build(final BuildContext context) =>
      Column(children: buildGridded(context: context));
}
