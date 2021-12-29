import 'package:flutter/material.dart';
import '../../../../../../modules/helpers/assets.dart';
import '../../../../../../modules/helpers/ui.dart';
import '../../../controller.dart';

class MangaHero extends StatelessWidget {
  const MangaHero({
    required final this.controller,
    final Key? key,
  }) : super(key: key);

  final MangaPageController controller;

  @override
  Widget build(final BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    final Widget image = controller.info.value!.thumbnail != null
        ? Image.network(
            controller.info.value!.thumbnail!.url,
            headers: controller.info.value!.thumbnail!.headers,
            width: remToPx(7),
            fit: BoxFit.cover,
          )
        : Image.asset(
            Assets.placeholderImageFromContext(context),
            width: remToPx(7),
            fit: BoxFit.cover,
          );

    final Widget left = ClipRRect(
      borderRadius: BorderRadius.circular(remToPx(0.2)),
      child: SizedBox(
        width: width > ResponsiveSizes.md ? (15 / 100) * width : remToPx(8),
        child: image,
      ),
    );

    final Widget right = Column(
      children: <Widget>[
        Text(
          controller.info.value!.title,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.headline4?.fontSize,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          controller.extractor!.name,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: Theme.of(context).textTheme.headline6?.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    if (width > ResponsiveSizes.md) {
      return Row(
        children: <Widget>[
          left,
          SizedBox(width: remToPx(1.5)),
          Expanded(child: right),
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          left,
          SizedBox(height: remToPx(1)),
          right,
        ],
      );
    }
  }
}
