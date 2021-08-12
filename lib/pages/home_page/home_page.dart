import 'package:flutter/material.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/translator/translator.dart';

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  @override
  Widget build(final BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
          vertical: remToPx(1),
          horizontal: remToPx(1.25),
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
