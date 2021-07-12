import 'package:flutter/material.dart';
import '../../components/bottom_bar.dart' as bottom_bar;
import '../../plugins/router.dart';

class Page extends StatefulWidget {
  const Page({Key? key}) : super(key: key);

  @override
  State<Page> createState() => PageState();
}

class PageState extends State<Page> {
  late int currentIndex;
  final List<RouteInfo> stack = [
    RouteManager.routes[RouteNames.home]!,
    RouteManager.routes[RouteNames.search]!,
  ];
  final List<RouteInfo> routes = [
    RouteManager.routes[RouteNames.settings]!,
  ];

  int? getIndexOfRoute(String route) =>
      stack.indexWhere((x) => x.route == route);

  @override
  void initState() {
    super.initState();

    currentIndex = (RouteManager.keeper.currentRoute != null
            ? getIndexOfRoute(RouteManager.keeper.currentRoute!.settings.name!)
            : null) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: stack.map((x) => x.builder(context)).toList(),
        ),
      ),
      bottomNavigationBar: bottom_bar.BottomBar(
        initialIndex: currentIndex,
        items: [
          ...(stack
              .asMap()
              .map((i, x) {
                return MapEntry(
                    i,
                    bottom_bar.BottomBarItem(
                      name: x.name!,
                      icon: x.icon!,
                      onPressed: () {
                        setState(() {
                          currentIndex = i;
                        });
                      },
                    ));
              })
              .values
              .toList()),
          ...(routes
              .asMap()
              .map((i, x) {
                return MapEntry(
                    i,
                    bottom_bar.BottomBarItem(
                      name: x.name!,
                      icon: x.icon!,
                      onPressed: () {
                        Navigator.of(context).pushNamed(x.route);
                      },
                    ));
              })
              .values
              .toList()),
        ],
      ),
    );
  }
}
