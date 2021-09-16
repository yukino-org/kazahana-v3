import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/page_args/anilist_page.dart' as anilist_page;
import '../../../core/trackers/anilist/anilist.dart' as anilist;
import '../../../plugins/helpers/assets.dart';
import '../../../plugins/helpers/ui.dart';
import '../../../plugins/helpers/utils/string.dart';
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
  final bool Function() loggedIn;
}

class TrackersPage extends StatefulWidget {
  const TrackersPage({
    final Key? key,
  }) : super(key: key);

  @override
  _TrackersPageState createState() => _TrackersPageState();
}

class _TrackersPageState extends State<TrackersPage> with RouteAware {
  final List<TrackerRoute> connections = <TrackerRoute>[
    ...anilist.MediaType.values.map(
      (final anilist.MediaType type) => TrackerRoute(
        name:
            '${Translator.t.anilist()} - ${StringUtils.capitalize(type.type)}',
        image: Assets.anilistLogo,
        route: ParsedRouteInfo(
          RouteManager.routes[RouteNames.anilistPage]!.route,
          anilist_page.PageArguments(
            type: type,
          ).toJson(),
        ).toString(),
        loginURL: anilist.AnilistManager.auth.getOauthURL(),
        loggedIn: anilist.AnilistManager.auth.isValidToken,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(Duration.zero, () {
      RouteManager.observer.subscribe(this, ModalRoute.of(context)!);
    });
  }

  @override
  void dispose() {
    RouteManager.observer.unsubscribe(this);

    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {});
  }

  @override
  Widget build(final BuildContext context) => Column(
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
            (final TrackerRoute tracker) {
              final bool loggedIn = tracker.loggedIn();

              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    if (loggedIn) {
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
                        if (MediaQuery.of(context).size.width >
                            ResponsiveSizes.md)
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
                              loggedIn
                                  ? Translator.t.view()
                                  : Translator.t.logIn(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
}
