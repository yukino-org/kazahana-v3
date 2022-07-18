import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/exports.dart';
import '../../../components/exports.dart';

class AnilistMediaSlide extends StatefulWidget {
  const AnilistMediaSlide(
    this.anime, {
    final Key? key,
  }) : super(key: key);

  final AnilistMedia anime;

  @override
  State<AnilistMediaSlide> createState() => _AnilistMediaSlideState();
}

class _AnilistMediaSlideState extends State<AnilistMediaSlide>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(final BuildContext context) {
    super.build(context);
    return Stack(
      children: <Widget>[
        Container(color: Theme.of(context).bottomAppBarColor),
        Positioned.fill(
          child: FadeInImage(
            placeholder: MemoryImage(Placeholders.transparent1x1Image),
            image: NetworkImage(
              widget.anime.bannerImage ?? widget.anime.coverImageExtraLarge,
            ),
            fit: BoxFit.cover,
          ),
        ),
        if (widget.anime.bannerImage == null)
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: const SizedBox.expand(),
            ),
          ),
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
                    child: FadeInImage(
                      placeholder:
                          MemoryImage(Placeholders.transparent1x1Image),
                      image: NetworkImage(widget.anime.coverImageExtraLarge),
                    ),
                  ),
                ),
                SizedBox(height: rem(0.5)),
                Wrap(
                  spacing: rem(0.25),
                  children: <Widget>[
                    AnilistMediaTile.buildChip(
                      context: context,
                      icon: widget.anime.status == AnilistMediaStatus.releasing
                          ? AnilistMediaTile.ongoingIcon
                          : null,
                      child: Text(widget.anime.format.titleCase),
                    ),
                    AnilistMediaTile.buildChip(
                      context: context,
                      icon: AnilistMediaTile.popularityIcon,
                      child: Text(widget.anime.popularity.toString()),
                    ),
                    if (widget.anime.averageScore != null)
                      AnilistMediaTile.buildChip(
                        context: context,
                        icon: AnilistMediaTile.ratingIcon,
                        child: Text('${widget.anime.averageScore}%'),
                      ),
                    if (widget.anime.startDate != null ||
                        widget.anime.endDate != null)
                      AnilistMediaTile.buildChip(
                        context: context,
                        icon: Icon(
                          Icons.sync_alt,
                          color: ColorPalettes.fuchsia.c500,
                        ),
                        child: Text(
                          '${prettyAnilistFuzzyDate(widget.anime.startDate)} - ${prettyAnilistFuzzyDate(widget.anime.endDate)}',
                        ),
                      ),
                  ],
                ),
                SizedBox(height: rem(0.25)),
                Text(
                  widget.anime.titleUserPreferred,
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: rem(0.25)),
                if (widget.anime.description != null)
                  Text(
                    widget.anime.description!,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String prettyAnilistFuzzyDate(final AnilistFuzzyDate? date) =>
      date?.isValidDateTime ?? false ? date!.pretty : '?';

  @override
  bool get wantKeepAlive => true;
}
