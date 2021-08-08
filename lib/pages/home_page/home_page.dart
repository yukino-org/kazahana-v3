import 'package:flutter/material.dart';
import '../../core/utils.dart' as utils;
import '../../plugins/translator/translator.dart';

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  State<Page> createState() => PageState();
}

class PageState extends State<Page> {
  @override
  Widget build(final BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
          vertical: utils.remToPx(1),
          horizontal: utils.remToPx(1.25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              Translator.t.home(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: Theme.of(context).textTheme.headline6?.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
}
