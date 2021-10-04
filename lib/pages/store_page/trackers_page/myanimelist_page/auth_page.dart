import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/trackers/myanimelist/myanimelist.dart' as myanimelist;
import '../../../../plugins/helpers/assets.dart';
import '../../../../plugins/helpers/logger.dart';
import '../../../../plugins/helpers/stateful_holder.dart';
import '../../../../plugins/helpers/ui.dart';
import '../../../../plugins/router.dart';
import '../../../../plugins/translator/translator.dart';

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  final StatefulHolder<List<InlineSpan>> status =
      StatefulHolder<List<InlineSpan>>(<InlineSpan>[
    TextSpan(text: Translator.t.authenticating()),
  ]);

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(Duration.zero, () async {
      try {
        final ParsedRouteInfo args =
            ParsedRouteInfo.fromURI(ModalRoute.of(context)!.settings.name!);
        await myanimelist.MyAnimeListManager.authenticate(args.params['code']!);

        if (mounted) {
          setState(() {
            status.resolve(<InlineSpan>[
              TextSpan(text: Translator.t.successfullyAuthenticated()),
            ]);
          });

          Future<void>.delayed(const Duration(seconds: 4), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      } catch (err, stack) {
        Logger.of('anilist_page/auth_page')
            .error('Authentication failed: $err', stack);

        if (mounted) {
          setState(() {
            status.fail(
              <InlineSpan>[
                TextSpan(text: Translator.t.authenticationFailed()),
                TextSpan(
                  text: '\n${err.toString()}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.caption?.color,
                  ),
                ),
              ],
            );
          });
        }
      }
    });
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(Translator.t.myAnimeList()),
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
                      Assets.myAnimeListLogo,
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
                RichText(
                  text: TextSpan(
                    children: status.value,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
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
