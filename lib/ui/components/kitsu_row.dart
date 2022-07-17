import 'package:flutter/material.dart';
import 'package:utilx/utils.dart';
import '../../core/exports.dart';
import 'kitsu_tile.dart';

class KitsuRow extends StatelessWidget {
  const KitsuRow(
    this.results, {
    final Key? key,
  }) : super(key: key);

  final List<dynamic> results;

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
                    (final dynamic x) => SizedBox(
                      width: rem(7.5),
                      child: KitsuTile(x),
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
