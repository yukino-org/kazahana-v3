import 'package:kazahana/core/exports.dart';
import '../../../../../exports.dart';
import 'provider.dart';

class AnilistPageProfileBodyBody extends StatelessWidget {
  const AnilistPageProfileBodyBody({
    required this.provider,
    super.key,
  });

  final AnilistPageProfileProvider provider;

  Widget buildOnWaiting(final BuildContext context) => SizedBox(
        height: context.r.scale(12),
        child: const Center(child: CircularProgressIndicator()),
      );

  Widget buildGridRow({
    required final BuildContext context,
    required final List<Widget> children,
  }) =>
      Padding(
        padding: EdgeInsets.only(bottom: context.r.scale(1)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ListUtils.insertBetween(
            children.map((final Widget x) => Expanded(child: x)).toList(),
            SizedBox(width: context.r.scale(1)),
          ),
        ),
      );

  String getMediaProgressText(final AnilistMedia media) => switch (media.type) {
        AnilistMediaType.anime =>
          '${media.mediaListEntry?.progress ?? 0}/${media.episodes ?? Translation.unk}',
        AnilistMediaType.manga => <String>[
            '${media.mediaListEntry?.progress ?? 0}/${media.episodes ?? 0}',
            '(${media.mediaListEntry?.progressVolumes ?? 0}/${media.volumes ?? Translation.unk})',
          ].join(' '),
      };

  List<Widget> buildTiles({
    required final BuildContext context,
    required final List<AnilistMedia> list,
  }) =>
      list
          .map(
            (final AnilistMedia x) => AnilistMediaTile(
              x,
              additionalBottomChips: <Widget>[
                AnilistMediaTile.buildChip(
                  context: context,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  child: Text(getMediaProgressText(x)),
                ),
              ],
            ),
          )
          .toList();

  @override
  Widget build(final BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: HorizontalBodyPadding.paddingValue(context),
          vertical: context.r.scale(0.5),
        ),
        child: StatedBuilder(
          provider.list.state,
          waiting: buildOnWaiting,
          processing: buildOnWaiting,
          finished: (final _) => Column(
            children: ListUtils.chunk(
              buildTiles(context: context, list: provider.list.value.last),
              2,
              const SizedBox.shrink(),
            )
                .map(
                  (final List<Widget> x) =>
                      buildGridRow(context: context, children: x),
                )
                .toList(),
          ),
          failed: (final _) => Text('Error: ${provider.list.error}'),
        ),
      );
}
