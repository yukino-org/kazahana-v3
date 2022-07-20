import '../../../../core/exports.dart';
import '../../../components/exports.dart';
import '../../../exports.dart';
import '../provider.dart';

class ViewPageBody extends StatelessWidget {
  const ViewPageBody({
    final Key? key,
  }) : super(key: key);

  Widget position(
    final Widget child, {
    final AlignmentGeometry? align,
    final bool pad = true,
    final double? padHorizontal,
    final double? padVertical,
  }) {
    Widget pChild = child;
    if (pad) {
      pChild = Padding(
        padding: EdgeInsets.symmetric(
          horizontal: padHorizontal ?? rem(0.75),
          vertical: padVertical ?? 0,
        ),
        child: child,
      );
    }
    if (align != null) {
      pChild = Align(alignment: align, child: pChild);
    }
    return pChild;
  }

  Widget buildCharacterTile({
    required final BuildContext context,
    required final AnilistCharacterEdge character,
  }) =>
      SizedBox(
        width: AnilistMediaRow.tileWidth,
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
                        character.node.imageLarge,
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
                              AnilistMediaTile.buildChip(
                                context: context,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                textColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                child: Text(character.role.titleCase),
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
                character.node.nameUserPreferred,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(final BuildContext context) {
    final ViewPageProvider provider = context.watch<ViewPageProvider>();
    final AnilistMedia media = provider.media.value;

    return SingleChildScrollView(
      child: Column(
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
          position(
            Text(
              media.titleUserPreferred,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyText1!.color,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: rem(0.2)),
          position(
            Text(
              <String>[
                media.format.titleCase,
                media.watchtime,
                if (media.season != null || media.seasonYear != null)
                  '${media.season?.titleCase ?? '?'} ${media.seasonYear ?? '?'}',
                media.status.titleCase,
              ].join(' | '),
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Theme.of(context).textTheme.caption!.color),
            ),
            align: Alignment.center,
          ),
          SizedBox(height: rem(0.5)),
          position(
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
          ),
          SizedBox(height: rem(0.25)),
          position(
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
          ),
          if (media.description != null) ...<Widget>[
            SizedBox(height: rem(0.75)),
            position(Text(media.description!), align: Alignment.topLeft),
          ],
          SizedBox(height: rem(1)),
          position(
            Text(
              Translator.t.characters(),
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            align: Alignment.topLeft,
          ),
          SizedBox(height: rem(0.5)),
          position(
            ScrollableRow(
              media.characters
                  .map(
                    (final AnilistCharacterEdge x) => buildCharacterTile(
                      context: context,
                      character: x,
                    ),
                  )
                  .toList(),
            ),
            align: Alignment.topLeft,
            pad: false,
          ),
          if (media.relations != null) ...<Widget>[
            SizedBox(height: rem(1)),
            position(
              Text(
                Translator.t.relations(),
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              align: Alignment.topLeft,
            ),
            SizedBox(height: rem(0.5)),
            position(
              ScrollableRow(
                media.relations!
                    .map(
                      (final AnilistRelationEdge x) => SizedBox(
                        width: AnilistMediaRow.tileWidth,
                        child: AnilistMediaTile(
                          x.node,
                          additionalBottomChips: <Widget>[
                            AnilistMediaTile.buildChip(
                              context: context,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              textColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              child: Text(x.relationType.titleCase),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              align: Alignment.topLeft,
              pad: false,
            ),
          ],
          SizedBox(height: rem(1)),
        ],
      ),
    );
  }
}
