import 'package:flutter/material.dart';
import 'package:utilx/utils.dart';
import '../../core/exports.dart';

class KitsuTile extends StatelessWidget {
  const KitsuTile(
    this.item, {
    final Key? key,
  }) : super(key: key);

  final dynamic item;

  @override
  Widget build(final BuildContext context) {
    final String title;
    final String thumbnail;
    final String subtype;
    final String? rating;
    final int? ranking;

    switch (item.runtimeType) {
      case KitsuAnime:
        final KitsuAnime anime = item as KitsuAnime;
        title = anime.canonicalTitle;
        thumbnail = anime.posterImageOriginal;
        subtype = anime.subtype.titleCase;
        rating = anime.averageRating;
        ranking = anime.popularityRank;
        break;

      case KitsuManga:
        final KitsuManga manga = item as KitsuManga;
        title = manga.canonicalTitle;
        thumbnail = manga.posterImageOriginal;
        subtype = manga.subtype.titleCase;
        rating = manga.averageRating;
        ranking = manga.popularityRank;
        break;

      default:
        throw Error();
    }

    return InkWell(
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
                    child: Container(
                      color: Theme.of(context).bottomAppBarColor,
                    ),
                  ),
                  Positioned.fill(
                    child: Image.network(
                      thumbnail,
                      fit: BoxFit.cover,
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
                                icon: rankingIcon,
                                child: Text(ranking.toString()),
                              ),
                            if (rating != null)
                              buildChip(
                                context: context,
                                icon: ratingIcon,
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
    );
  }

  static Widget buildChip({
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

  static Icon get ratingIcon =>
      Icon(Icons.star, color: ColorPalettes.yellow.c500);

  static Icon get rankingIcon =>
      Icon(Icons.tag, color: ColorPalettes.blue.c500);
}
