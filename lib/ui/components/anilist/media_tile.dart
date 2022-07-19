import '../../../core/exports.dart';
import '../../exports.dart';

class AnilistMediaTile extends StatelessWidget {
  const AnilistMediaTile(
    this.media, {
    this.additionalBottomChips = const <Widget>[],
    final Key? key,
  }) : super(key: key);

  final AnilistMedia media;
  final List<Widget> additionalBottomChips;

  @override
  Widget build(final BuildContext context) => InkWell(
        onTap: () {
          Navigator.of(context).pusher.pushToViewPageFromMedia(media);
        },
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
      );

  static Widget buildChip({
    required final BuildContext context,
    required final Widget child,
    final Widget? icon,
    final Color? color,
  }) =>
      DecoratedBox(
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).bottomAppBarColor,
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

  static Icon get ongoingIcon =>
      Icon(Icons.trip_origin, color: ColorPalettes.green.c500);

  static Icon get airdateIcon =>
      Icon(Icons.sync_alt, color: ColorPalettes.fuchsia.c500);

  static Widget buildFormatChip({
    required final BuildContext context,
    required final AnilistMedia media,
  }) =>
      AnilistMediaTile.buildChip(
        context: context,
        icon: media.status == AnilistMediaStatus.releasing
            ? AnilistMediaTile.ongoingIcon
            : null,
        child: Text(media.format.titleCase),
      );

  static Widget buildWatchtimeChip({
    required final BuildContext context,
    required final AnilistMedia media,
  }) =>
      AnilistMediaTile.buildChip(
        context: context,
        child: Text(media.watchtime),
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
        child: Text(
          '${prettyAnilistFuzzyDate(media.startDate)} - ${prettyAnilistFuzzyDate(media.endDate)}',
        ),
      );

  static Widget buildNSFWChip({
    required final BuildContext context,
    required final AnilistMedia media,
  }) =>
      AnilistMediaTile.buildChip(
        context: context,
        color: ColorPalettes.red.c500,
        child: Text(Translator.t.nsfw()),
      );

  static String prettyAnilistFuzzyDate(final AnilistFuzzyDate? date) =>
      date?.isValidDateTime ?? false ? date!.pretty : '?';
}
