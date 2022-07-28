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
                width: context.r.size(tileWidthScale),
                child: AnilistMediaTile(x),
              ),
            )
            .toList(),
      );

  static const double tileWidthScale = 7.5;
}
