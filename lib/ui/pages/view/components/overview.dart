import '../../../../core/exports.dart';
import '../../../exports.dart';

class ViewPageOverview extends StatelessWidget {
  const ViewPageOverview(
    this.media, {
    final Key? key,
  }) : super(key: key);

  final AnilistMedia media;

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
  Widget build(final BuildContext context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (media.description != null) ...<Widget>[
                SizedBox(height: rem(0.75)),
                HorizontalBodyPadding(Text(media.description!)),
              ],
              SizedBox(height: rem(1)),
              HorizontalBodyPadding(
                Text(
                  Translator.t.characters(),
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: rem(0.5)),
              ScrollableRow(
                media.characters
                    .map(
                      (final AnilistCharacterEdge x) =>
                          buildCharacterTile(context: context, character: x),
                    )
                    .toList(),
              ),
              if (media.relations?.isNotEmpty ?? false) ...<Widget>[
                SizedBox(height: rem(1)),
                HorizontalBodyPadding(
                  Text(
                    Translator.t.relations(),
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: rem(0.5)),
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
              ],
            ],
          ),
        ),
      );
}
