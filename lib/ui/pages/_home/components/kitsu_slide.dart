import 'package:flutter/material.dart';
import '../../../../core/exports.dart';
import '../../../components/exports.dart';

class KitsuSlide extends StatefulWidget {
  const KitsuSlide(
    this.anime, {
    final Key? key,
  }) : super(key: key);

  final KitsuAnime anime;

  @override
  _KitsuSlideState createState() => _KitsuSlideState();
}

class _KitsuSlideState extends State<KitsuSlide> {
  late final Image? coverImage = Image.network(
    widget.anime.coverImageOriginal ?? widget.anime.posterImageOriginal,
    fit: BoxFit.cover,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (coverImage == null) return;
    precacheImage(coverImage!.image, context);
  }

  @override
  Widget build(final BuildContext context) => Stack(
        children: <Widget>[
          Container(color: Theme.of(context).bottomAppBarColor),
          if (coverImage != null) Positioned.fill(child: coverImage!),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Theme.of(context).bottomAppBarColor.withOpacity(0.25),
                    Theme.of(context).bottomAppBarColor,
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.all(rem(0.75)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(rem(0.5)),
                      child: Image.network(widget.anime.posterImageOriginal),
                    ),
                  ),
                  SizedBox(height: rem(0.5)),
                  Wrap(
                    spacing: rem(0.25),
                    children: <Widget>[
                      KitsuTile.buildChip(
                        context: context,
                        child: Text(widget.anime.subtype.titleCase),
                      ),
                      if (widget.anime.popularityRank != null)
                        KitsuTile.buildChip(
                          context: context,
                          icon: KitsuTile.rankingIcon,
                          child: Text(widget.anime.popularityRank.toString()),
                        ),
                      if (widget.anime.averageRating != null)
                        KitsuTile.buildChip(
                          context: context,
                          icon: KitsuTile.ratingIcon,
                          child: Text(widget.anime.averageRating.toString()),
                        ),
                      if (widget.anime.startDate != null ||
                          widget.anime.endDate != null)
                        KitsuTile.buildChip(
                          context: context,
                          icon: Icon(
                            Icons.sync_alt,
                            color: ColorPalettes.fuchsia.c500,
                          ),
                          child: Text(
                            '${prettyDate(widget.anime.startDate)} - ${prettyDate(widget.anime.endDate)}',
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: rem(0.25)),
                  Text(
                    widget.anime.canonicalTitle,
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: rem(0.25)),
                  if (widget.anime.synopsis != null)
                    Text(
                      widget.anime.synopsis!,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ],
      );

  String prettyDate(final DateTime? date) =>
      date != null ? PrettyDates.toDateString(date) : '?';
}
