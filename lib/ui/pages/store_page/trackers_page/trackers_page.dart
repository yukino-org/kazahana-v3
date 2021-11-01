import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import './anilist_page/anilist_page.dart' as anilist_page;
import './myanimelist_page/myanimelist_page.dart' as myanimelist_page;
import '../../../../modules/helpers/assets.dart';
import '../../../../modules/helpers/ui.dart';
import '../../../../modules/state/hooks.dart';
import '../../../../modules/trackers/anilist/anilist.dart';
import '../../../../modules/trackers/myanimelist/myanimelist.dart';
import '../../../../modules/translator/translator.dart';
import '../../../../modules/utils/utils.dart';
import '../../../router.dart';

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

class _TrackersPageState extends State<TrackersPage>
    with RouteAware, HooksMixin {
  final List<TrackerRoute> connections = <TrackerRoute>[
    ...ExtensionType.values.map(
      (final ExtensionType type) => TrackerRoute(
        name:
            '${Translator.t.anilist()} - ${StringUtils.capitalize(type.type)}',
        image: Assets.anilistLogo,
        route: ParsedRouteInfo(
          RouteManager.routes[RouteNames.anilistPage]!.route,
          anilist_page.PageArguments(
            type: type,
          ).toJson(),
        ).toString(),
        loginURL: AnilistManager.auth.getOauthURL(),
        loggedIn: AnilistManager.auth.isValidToken,
      ),
    ),
    ...ExtensionType.values.map(
      (final ExtensionType type) => TrackerRoute(
        name:
            '${Translator.t.myAnimeList()} - ${StringUtils.capitalize(type.type)}',
        image: Assets.myAnimeListLogo,
        route: ParsedRouteInfo(
          RouteManager.routes[RouteNames.myAnimeListPage]!.route,
          myanimelist_page.PageArguments(
            type: type,
          ).toJson(),
        ).toString(),
        loginURL: MyAnimeListManager.auth.getOauthURL(),
        loggedIn: MyAnimeListManager.auth.isValidToken,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();

    onReady(() async {
      RouteManager.observer.subscribe(this, ModalRoute.of(context)!);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    hookState.markReady();
  }

  @override
  void dispose() {
    RouteManager.observer.unsubscribe(this);

    super.dispose();
  }

  @override
  void didPopNext() {
    if (mounted) {
      setState(() {});
    }
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
                          )
                        else
                          Padding(
                            padding: EdgeInsets.only(
                              left: remToPx(0.75),
                              right: remToPx(0.25),
                            ),
                            child: Icon(
                              loggedIn ? Icons.check : Icons.login,
                              color: loggedIn
                                  ? Colors.green[400]
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      ?.color
                                      ?.withOpacity(0.5),
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
