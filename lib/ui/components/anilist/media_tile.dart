import 'package:kazahana/core/exports.dart';
import '../../exports.dart';

class AnilistMediaTile extends StatelessWidget {
  const AnilistMediaTile(
    this.media, {
    this.additionalBottomChips = const <Widget>[],
    super.key,
  });

  final AnilistMedia media;
  final List<Widget> additionalBottomChips;

  @override
  Widget build(final BuildContext context) => InkWell(
        onTap: () {
          Navigator.of(context).pusher.pushToViewPageFromMedia(media);
        },
        borderRadius: BorderRadius.circular(context.r.scale(0.25)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(context.r.scale(0.25)),
              child: AspectRatio(
                aspectRatio: coverRatio,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Container(
                        color: Theme.of(context).bottomAppBarTheme.color,
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
                        padding: EdgeInsets.all(context.r.scale(0.25)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: ListUtils.insertBetween(
                            <Widget>[
                              if (media.averageScore != null)
                                buildRatingChip(
                                  context: context,
                                  media: media,
                                ),
                              buildWatchtimeChip(
                                context: context,
                                media: media,
                              ),
                              buildFormatChip(
                                context: context,
                                media: media,
                              ),
                              if (media.isAdult)
                                AnilistMediaTile.buildNSFWChip(
                                  context: context,
                                  media: media,
                                ),
                              ...additionalBottomChips,
                            ],
                            SizedBox(height: context.r.scale(0.2)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.r.scale(0.25)),
            Flexible(
              child: Text(
                media.titleUserPreferred,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );

  static const double coverRatio = 5 / 8;

  static Widget buildChip({
    required final BuildContext context,
    required final Widget child,
    final Widget? icon,
    final Color? backgroundColor,
    final Color? textColor,
  }) =>
      DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).bottomAppBarTheme.color,
          borderRadius: BorderRadius.circular(context.r.scale(0.2)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.r.scale(0.2)),
          child: DefaultTextStyle(
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(fontWeight: FontWeight.normal, color: textColor),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  IconTheme(
                    data: Theme.of(context)
                        .iconTheme
                        .copyWith(size: context.r.scale(0.65)),
                    child: icon,
                  ),
                  SizedBox(width: context.r.scale(0.15)),
                ],
                child,
              ],
            ),
          ),
        ),
      );

  static Widget buildFormatChip({
    required final BuildContext context,
    required final AnilistMedia media,
  }) =>
      AnilistMediaTile.buildChip(
        context: context,
        icon: media.status == AnilistMediaStatus.releasing
            ? AnilistMediaTile.ongoingIcon
            : null,
        child: Text(media.format.getTitleCase(context.t)),
      );

  static Widget buildWatchtimeChip({
    required final BuildContext context,
    required final AnilistMedia media,
  }) =>
      AnilistMediaTile.buildChip(
        context: context,
        child: Text(media.getWatchtime(context.t)),
      );

  static Widget buildRatingChip({
    required final BuildContext context,
    required final AnilistMedia media,
  }) =>
      AnilistMediaTile.buildChip(
        context: context,
        icon: AnilistMediaTile.ratingIcon,
        child: Text('${media.averageScore}%'),
      );

  static Widget buildAirdateChip({
    required final BuildContext context,
    required final AnilistMedia media,
  }) =>
      AnilistMediaTile.buildChip(
        context: context,
        icon: airdateIcon,
        child: Text(media.airdate),
      );

  static Widget buildNSFWChip({
    required final BuildContext context,
    required final AnilistMedia media,
  }) =>
      AnilistMediaTile.buildChip(
        context: context,
        backgroundColor: ForegroundColors.red,
        child: Text(context.t.nsfw),
      );

  static const Icon ratingIcon = Icon(
    Icons.star_rounded,
    color: ForegroundColors.yellow,
  );

  static const Icon ongoingIcon = Icon(
    Icons.fiber_manual_record_outlined,
    color: ForegroundColors.green,
  );

  static const Icon airdateIcon = Icon(
    Icons.date_range_rounded,
    color: ForegroundColors.fuchsia,
  );
}
