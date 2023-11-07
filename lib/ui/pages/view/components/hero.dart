import 'package:kazahana/core/exports.dart';
import '../../../exports.dart';

class ViewPageHero extends StatelessWidget {
  const ViewPageHero(
    this.media, {
    super.key,
  });

  final AnilistMedia media;

  @override
  Widget build(final BuildContext context) {
    final Color chipBackgroundColor =
        Theme.of(context).colorScheme.secondaryContainer;
    final Color chipTextColor =
        Theme.of(context).colorScheme.onSecondaryContainer;
    final double bannerHeight = context.r.scale(10, md: 15);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: context.r.scale(15, md: 20),
          child: Stack(
            children: <Widget>[
              SizedBox(
                height: bannerHeight,
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
                height: bannerHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.transparent,
                        Theme.of(context)
                            .bottomAppBarTheme
                            .color!
                            .withOpacity(0.75),
                      ],
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              if (media.bannerImage == null)
                SizedBox(
                  height: bannerHeight,
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
                  borderRadius: BorderRadius.circular(context.r.scale(0.5)),
                  child: Image.network(
                    media.coverImageExtraLarge,
                    height: context.r.scale(10, md: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.r.scale(1)),
        HorizontalBodyPadding(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                media.titleUserPreferred,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.r.scale(0.2)),
              Text(
                <String>[
                  media.format.getTitleCase(context.t),
                  media.getWatchtime(context.t),
                  if (media.season != null || media.seasonYear != null)
                    '${media.season?.getTitleCase(context.t) ?? Translation.unk} ${media.seasonYear ?? Translation.unk}',
                  media.status.getTitleCase(context.t),
                ].join(' | '),
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).textTheme.bodySmall!.color,
                    ),
              ),
              SizedBox(height: context.r.scale(0.75)),
              Wrap(
                spacing: context.r.scale(0.4),
                runSpacing: context.r.scale(0.2),
                children: <Widget>[
                  if (media.averageScore != null)
                    AnilistMediaTile.buildRatingChip(
                      context: context,
                      media: media,
                      backgroundColor: chipBackgroundColor,
                      textColor: chipTextColor,
                    ),
                  if (media.startDate != null || media.endDate != null)
                    AnilistMediaTile.buildAirdateChip(
                      context: context,
                      media: media,
                      backgroundColor: chipBackgroundColor,
                      textColor: chipTextColor,
                    ),
                  if (media.isAdult)
                    AnilistMediaTile.buildNSFWChip(
                      context: context,
                      media: media,
                    ),
                ],
              ),
              SizedBox(height: context.r.scale(0.4)),
              Wrap(
                spacing: context.r.scale(0.4),
                runSpacing: context.r.scale(0.2),
                children: media.genres
                    .map(
                      (final String x) => AnilistMediaTile.buildChip(
                        context: context,
                        child: Text(x),
                        backgroundColor: chipBackgroundColor,
                        textColor: chipTextColor,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        SizedBox(height: context.r.scale(0.5)),
      ],
    );
  }
}
