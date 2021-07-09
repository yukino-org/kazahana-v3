import 'package:flutter/material.dart';
import '../core/utils.dart' as utils;
import '../plugins/routes.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar> {
  int routeIndex = 0;

  @override
  initState() {
    super.initState();

    RouteManager.keeper.observer.subscribe(updateRoute);
  }

  @override
  void dispose() {
    RouteManager.keeper.observer.unsubscribe(updateRoute);

    super.dispose();
  }

  void updateRoute(Route<dynamic>? current, Route<dynamic>? previous) {
    if (current != null) {
      final newIndex = RouteManager.labeledRoutes
          .indexWhere((x) => x.route == current.settings.name);

      if (routeIndex != newIndex) {
        setState(() {
          routeIndex = newIndex;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        padding: EdgeInsets.all(utils.remToPx(0.2)),
        child: Wrap(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: RouteManager.labeledRoutes.map((x) {
                final i = RouteManager.labeledRoutes.indexOf(x);
                final isActive = routeIndex == i;
                final color = isActive
                    ? Theme.of(context).primaryColor
                    : Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.color
                        ?.withOpacity(0.7);

                return MaterialButton(
                  padding: EdgeInsets.all(utils.remToPx(0.2)),
                  shape: const CircleBorder(),
                  child: Column(
                    children: [
                      Icon(x.icon, size: utils.remToPx(1.25), color: color),
                      SizedBox(height: utils.remToPx(0.1)),
                      Text(
                        x.name,
                        style: TextStyle(
                          color: color,
                        ),
                      )
                    ],
                  ),
                  onPressed: () {
                    if (RouteManager.currentRoute != x.route) {
                      RouteManager.navigationKey.currentState
                          ?.pushNamed(x.route);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
