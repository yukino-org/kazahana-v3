import 'package:flutter/material.dart';
import 'package:tenka/tenka.dart';
import 'package:utilx/utils.dart';
import '../../../../core/exports.dart';
import '../../../components/exports.dart';

class ResultsGrid extends StatelessWidget {
  const ResultsGrid({
    required this.type,
    required this.results,
    final Key? key,
  }) : super(key: key);

  final TenkaType type;
  final List<dynamic> results;

  Widget buildGridRow(final List<Widget> children) => Padding(
        padding: EdgeInsets.only(bottom: rem(1)),
        child: Row(
          children: ListUtils.insertBetween(
            children.map((final Widget x) => Expanded(child: x)).toList(),
            SizedBox(width: rem(1)),
          ),
        ),
      );

  List<Widget> buildTiles({
    required final BuildContext context,
  }) =>
      results.map((final dynamic x) => KitsuTile(x)).toList();

  @override
  Widget build(final BuildContext context) => Column(
        children: ListUtils.chunk(buildTiles(context: context), 2)
            .map(buildGridRow)
            .toList(),
      );
}
