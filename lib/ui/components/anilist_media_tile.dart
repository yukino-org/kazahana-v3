import 'package:flutter/material.dart';
import '../../core/exports.dart';

class AnilistMediaTile extends StatelessWidget {
  const AnilistMediaTile(
    this.media, {
    final Key? key,
  }) : super(key: key);

  final AnilistMedia media;

  @override
  Widget build(final BuildContext context) => InkWell(
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
                        media.coverImageExtraLarge,
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
                              buildChip(
                                context: context,
                                icon: popularityIcon,
                                child: Text(media.popularity.toString()),
                              ),
                              if (media.averageScore != null)
                                buildChip(
                                  context: context,
                                  icon: ratingIcon,
                                  child: Text('${media.averageScore}%'),
                                ),
                              buildChip(
                                context: context,
                                icon:
                                    media.status == AnilistMediaStatus.releasing
                                        ? ongoingIcon
                                        : null,
                                child: Text(media.format.titleCase),
                              ),
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
                media.titleUserPreferred,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        onTap: () {},
      );

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

  static Icon get popularityIcon =>
      Icon(Icons.tag, color: ColorPalettes.blue.c500);

  static Icon get ongoingIcon =>
      Icon(Icons.trip_origin, color: ColorPalettes.green.c500);
}
