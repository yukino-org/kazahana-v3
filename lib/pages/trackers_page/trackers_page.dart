import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/trackers/anilist/anilist.dart' as anilist;
import '../../../plugins/helpers/assets.dart';
import '../../../plugins/helpers/ui.dart';
import '../../../plugins/router.dart';
import '../../../plugins/translator/translator.dart';

class TrackerRoute {
  TrackerRoute({
    required final this.name,
    required final this.image,
    required final this.route,
    required final this.loginURL,
    required final this.loggedIn,
  });

  final String name;
  final String image;
  final String route;
  final String loginURL;
  final bool loggedIn;
}

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  final List<TrackerRoute> connections = <TrackerRoute>[
    TrackerRoute(
      name: Translator.t.anilist(),
      image: Assets.anilistLogo,
      route: RouteManager.routes[RouteNames.anilistPage]!.route,
      loginURL: anilist.AnilistManager.auth.getOauthURL(),
      loggedIn: anilist.AnilistManager.auth.isValidToken(),
    )
  ];

  @override
  Widget build(final BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(
          vertical: remToPx(1),
          horizontal: remToPx(1.25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              Translator.t.connections(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: Theme.of(context).textTheme.headline6?.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: remToPx(0.5),
            ),
            ...connections.map(
              (final TrackerRoute tracker) => Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    if (tracker.loggedIn) {
                      Navigator.of(context).pushNamed(tracker.route);
                    } else {
                      launch(tracker.loginURL);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: remToPx(0.6),
                      vertical: remToPx(0.5),
                    ),
                    child: Row(
                      children: <Widget>[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.9),
                            borderRadius: BorderRadiusDirectional.circular(
                              remToPx(0.2),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: remToPx(0.2),
                            ),
                            child: Image.asset(
                              tracker.image,
                              width: remToPx(2),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: remToPx(0.75),
                        ),
                        Expanded(
                          child: Text(
                            tracker.name,
                            style:
                                Theme.of(context).textTheme.headline6?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: remToPx(0.4),
                            vertical: remToPx(0.2),
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(remToPx(0.2)),
                          ),
                          child: Text(
                            tracker.loggedIn
                                ? Translator.t.view()
                                : Translator.t.logIn(),
                            style:
                                Theme.of(context).textTheme.bodyText1?.copyWith(
                                      color: Colors.white,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
