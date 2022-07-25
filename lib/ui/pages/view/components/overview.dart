import '../../../../core/exports.dart';
import '../../../exports.dart';

class ViewPageOverview extends StatelessWidget {
  const ViewPageOverview(
    this.media, {
    super.key,
  });

  final AnilistMedia media;

  Widget buildCharacterTile({
    required final BuildContext context,
    required final AnilistCharacterEdge character,
  }) =>
      SizedBox(
        width: context.r.size(AnilistMediaRow.tileWidthScale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(context.r.size(0.25)),
              child: AspectRatio(
                aspectRatio: AnilistMediaTile.coverRatio,
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
                        padding: EdgeInsets.all(context.r.size(0.25)),
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
                            SizedBox(height: context.r.size(0.2)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.r.size(0.25)),
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
                SizedBox(height: context.r.size(0.75)),
                HorizontalBodyPadding(Text(media.description!)),
              ],
              SizedBox(height: context.r.size(1)),
              HorizontalBodyPadding(
                Text(
                  Translator.t.characters(),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: context.r.size(0.5)),
              ScrollableRow(
                media.characters
                    .map(
                      (final AnilistCharacterEdge x) =>
                          buildCharacterTile(context: context, character: x),
                    )
                    .toList(),
              ),
              if (media.relations?.isNotEmpty ?? false) ...<Widget>[
                SizedBox(height: context.r.size(1)),
                HorizontalBodyPadding(
                  Text(
                    Translator.t.relations(),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: context.r.size(0.5)),
                ScrollableRow(
                  media.relations!
                      .map(
                        (final AnilistRelationEdge x) => SizedBox(
                          width: context.r.size(AnilistMediaRow.tileWidthScale),
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
