import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/trackers/anilist/anilist.dart' as anilist;
import '../../../../core/trackers/anilist/handlers/auth.dart';
import '../../../../plugins/helpers/assets.dart';
import '../../../../plugins/helpers/stateful_holder.dart';
import '../../../../plugins/helpers/ui.dart';
import '../../../../plugins/translator/translator.dart';

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  final StatefulHolder<String> status =
      StatefulHolder<String>(Translator.t.authenticating());

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(Duration.zero, () async {
      try {
        final TokenInfo token =
            TokenInfo.fromURL(ModalRoute.of(context)!.settings.name!);
        await anilist.AnilistManager.authenticate(token);

        if (mounted) {
          setState(() {
            status.resolve(Translator.t.successfullyAuthenticated());
          });

          Future<void>.delayed(const Duration(seconds: 4), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            status.fail(
              '${Translator.t.authenticationFailed()}\n${e.toString()}',
            );
          });
        }
      }
    });
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(Translator.t.anilist()),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
            vertical: remToPx(1),
            horizontal: remToPx(1.25),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(remToPx(1)),
                    child: Image.asset(
                      Assets.anilistLogo,
                      width:
                          MediaQuery.of(context).size.width > ResponsiveSizes.md
                              ? remToPx(7)
                              : remToPx(5),
                    ),
                  ),
                ),
                SizedBox(
                  height: remToPx(2),
                ),
                if (!status.hasEnded) ...<Widget>[
                  const CircularProgressIndicator(),
                  SizedBox(
                    height: remToPx(1),
                  ),
                ],
                Text(
                  status.value,
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: remToPx(2),
                ),
              ],
            ),
          ),
        ),
      );
}
