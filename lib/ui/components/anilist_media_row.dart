import 'package:flutter/material.dart';
import '../../core/exports.dart';
import 'anilist_media_tile.dart';

class AnilistMediaRow extends StatelessWidget {
  const AnilistMediaRow(
    this.results, {
    final Key? key,
  }) : super(key: key);

  final List<AnilistMedia> results;

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            spacer,
            ...ListUtils.insertBetween(
              results
                  .map(
                    (final AnilistMedia x) => SizedBox(
                      width: rem(7.5),
                      child: AnilistMediaTile(x),
                    ),
                  )
                  .toList(),
              spacer,
            ),
            spacer,
          ],
        ),
      );

  SizedBox get spacer => SizedBox(width: rem(0.75));
}
