import '../../../core/exports.dart';
import '../scrollable_row.dart';
import 'media_tile.dart';

class AnilistMediaRow extends StatelessWidget {
  const AnilistMediaRow(
    this.results, {
    final Key? key,
  }) : super(key: key);

  final List<AnilistMedia> results;

  @override
  Widget build(final BuildContext context) => ScrollableRow(
        results
            .map(
              (final AnilistMedia x) =>
                  SizedBox(width: tileWidth, child: AnilistMediaTile(x)),
            )
            .toList(),
      );

  static final double tileWidth = rem(7.5);
}
