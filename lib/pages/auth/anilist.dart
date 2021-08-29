import 'package:flutter/material.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/router.dart';
import '../../plugins/translator/translator.dart';

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  late ParsedRouteInfo route;

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(Duration.zero, () async {
      route = ParsedRouteInfo.fromSettings(ModalRoute.of(context)!.settings);
      print(route.route);
      print(route.params);
    });
  }

  @override
  Widget build(final BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
          vertical: remToPx(1),
          horizontal: remToPx(1.25),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircularProgressIndicator(),
            SizedBox(
              height: remToPx(0.2),
            ),
            Text(
              Translator.t.authenticating(),
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
      );
}
