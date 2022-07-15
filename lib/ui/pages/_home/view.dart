import 'package:flutter/material.dart';
import '../../../core/exports.dart';
import '../../router/exports.dart';

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
              icon: const Icon(Icons.search),
              onPressed: () {
                Beamer.of(context).beamToNamed(RouteNames.search);
              },
            ),
          ],
        ),
        body: const Center(child: Text('Home page moment')),
        bottomNavigationBar: Row(
          children: <Widget>[
            TextButton.icon(
              icon: const Icon(Icons.abc),
              label: Text(Translator.t.anime()),
              onPressed: () {},
            )
          ],
        ),
      );
}
