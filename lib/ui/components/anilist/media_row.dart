import 'package:kazahana/core/exports.dart';
import '../../exports.dart';

class AnilistMediaRow extends StatelessWidget {
  const AnilistMediaRow(
    this.results, {
    super.key,
  });

  final List<AnilistMedia> results;

  @override
  Widget build(final BuildContext context) => ScrollableRow(
        results
            .map(
              (final AnilistMedia x) => SizedBox(
                width: getTileWidth(context.r),
                child: AnilistMediaTile(x),
              ),
            )
            .toList(),
      );

  static const double tileWidthAny = 8;
  static const double tileWidthMd = 9;

  static double getTileWidth(final RelativeScaler r) =>
      r.scale(tileWidthAny, md: tileWidthMd);
}
