import 'package:flutter/material.dart';
import 'package:tenka/tenka.dart';
import 'package:utilx/utils.dart';
import '../../../../core/exports.dart';

class ResultsGrid extends StatelessWidget {
  const ResultsGrid({
    required this.type,
    required this.results,
    final Key? key,
  }) : super(key: key);

  final TenkaType type;
  final List<dynamic> results;

  Widget buildTile(
    final dynamic result, {
    required final BuildContext context,
  }) {
    final String title;
    final String thumbnail;

    switch (type) {
      case TenkaType.anime:
        final KitsuAnime anime = result as KitsuAnime;
        title = anime.canonicalTitle;
        thumbnail = anime.posterImageOriginal;
        break;

      case TenkaType.manga:
        final KitsuManga manga = result as KitsuManga;
        title = manga.canonicalTitle;
        thumbnail = manga.posterImageOriginal;
        break;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: rem(1)),
      child: InkWell(
        borderRadius: BorderRadius.circular(rem(0.25)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(rem(0.25)),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Image.network(thumbnail, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: rem(0.25)),
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  List<Widget> buildTiles({
    required final BuildContext context,
  }) =>
      results.map((final dynamic x) => buildTile(x, context: context)).toList();

  Widget buildGridRow(final List<Widget> children) => Row(
        children: ListUtils.insertBetween(
          children.map((final Widget x) => Expanded(child: x)).toList(),
          SizedBox(width: rem(1)),
        ),
      );

  List<Widget> buildGridded({
    required final BuildContext context,
  }) =>
      ListUtils.chunk(buildTiles(context: context), 2)
          .map(buildGridRow)
          .toList();

  @override
  Widget build(final BuildContext context) =>
      Column(children: buildGridded(context: context));
}
