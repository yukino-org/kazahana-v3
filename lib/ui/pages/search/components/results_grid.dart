import '../../../../core/exports.dart';
import '../../../exports.dart';

class ResultsGrid extends StatelessWidget {
  const ResultsGrid(
    this.results, {
    super.key,
  });

  final List<AnilistMedia> results;

  Widget buildGridRow({
    required final BuildContext context,
    required final List<Widget> children,
  }) =>
      Padding(
        padding: EdgeInsets.only(bottom: context.r.size(1)),
        child: Row(
          children: ListUtils.insertBetween(
            children.map((final Widget x) => Expanded(child: x)).toList(),
            SizedBox(width: context.r.size(1)),
          ),
        ),
      );

  List<Widget> buildTiles({
    required final BuildContext context,
  }) =>
      results.map((final AnilistMedia x) => AnilistMediaTile(x)).toList();

  @override
  Widget build(final BuildContext context) => Column(
        children: ListUtils.chunk(buildTiles(context: context), 2)
            .map(
              (final List<Widget> x) =>
                  buildGridRow(context: context, children: x),
            )
            .toList(),
      );
}
