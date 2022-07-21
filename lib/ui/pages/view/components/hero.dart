import '../../../../core/exports.dart';
import '../../../exports.dart';

class ViewPageHero extends StatelessWidget {
  const ViewPageHero(
    this.media, {
    final Key? key,
  }) : super(key: key);

  final AnilistMedia media;

  @override
  Widget build(final BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: rem(12),
            child: Stack(
              children: <Widget>[
                SizedBox(
                  height: rem(8),
                  width: double.infinity,
                  child: FadeInImage(
                    fit: BoxFit.cover,
                    placeholder: MemoryImage(Placeholders.transparent1x1Image),
                    image: NetworkImage(
                      media.bannerImage ?? media.coverImageExtraLarge,
                    ),
                  ),
                ),
                SizedBox(
                  height: rem(8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.transparent,
                          Theme.of(context).bottomAppBarColor.withOpacity(0.75),
                        ],
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                if (media.bannerImage == null)
                  SizedBox(
                    height: rem(8),
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(rem(0.5)),
                    child: Image.network(
                      media.coverImageExtraLarge,
                      height: rem(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: rem(0.75)),
          HorizontalBodyPadding(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  media.titleUserPreferred,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: rem(0.2)),
                Text(
                  <String>[
                    media.format.titleCase,
                    media.watchtime,
                    if (media.season != null || media.seasonYear != null)
                      '${media.season?.titleCase ?? '?'} ${media.seasonYear ?? '?'}',
                    media.status.titleCase,
                  ].join(' | '),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Theme.of(context).textTheme.caption!.color,
                      ),
                ),
                SizedBox(height: rem(0.5)),
                Wrap(
                  spacing: rem(0.25),
                  runSpacing: rem(0.2),
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    if (media.averageScore != null)
                      AnilistMediaTile.buildRatingChip(
                        context: context,
                        media: media,
                      ),
                    if (media.startDate != null || media.endDate != null)
                      AnilistMediaTile.buildAirdateChip(
                        context: context,
                        media: media,
                      ),
                    if (media.isAdult)
                      AnilistMediaTile.buildNSFWChip(
                        context: context,
                        media: media,
                      ),
                  ],
                ),
                SizedBox(height: rem(0.25)),
                Wrap(
                  spacing: rem(0.25),
                  runSpacing: rem(0.2),
                  alignment: WrapAlignment.center,
                  children: media.genres
                      .map(
                        (final String x) => AnilistMediaTile.buildChip(
                          context: context,
                          child: Text(x),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      );
}
