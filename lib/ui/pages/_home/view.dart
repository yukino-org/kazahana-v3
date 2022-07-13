import 'package:flutter/material.dart';

import '../../../core/exports.dart';

class UnderScoreHomePage extends StatefulWidget {
  const UnderScoreHomePage({
    final Key? key,
  }) : super(key: key);

  @override
  _UnderScoreHomePageState createState() => _UnderScoreHomePageState();
}

class _UnderScoreHomePageState extends State<UnderScoreHomePage> {
  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            AppMeta.name,
            style: Theme.of(context).textTheme.headline4!.copyWith(
                  fontFamily: Fonts.greatVibes,
                  color: Theme.of(context).textTheme.bodyText1?.color,
                ),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        body: Center(
          child: Text('Home page moment'),
        ),
      );
}
