import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../components/bottom_bar.dart' as bottom_bar;
import '../../plugins/router.dart';

class Page extends StatefulWidget {
  const Page({Key? key}) : super(key: key);

  @override
  State<Page> createState() => PageState();
}

class PageState extends State<Page> {
  late int currentIndex;
  late PageController controller;

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
    controller = PageController(initialPage: currentIndex, keepPage: true);
  }

  void goToPage(int page) => controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: SafeArea(
            child: PageView(
              onPageChanged: (page) {
                setState(() {
                  currentIndex = page;
                });
              },
              physics: const NeverScrollableScrollPhysics(),
              controller: controller,
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
                          name: x.name!(),
                          icon: x.icon!,
                          isActive: currentIndex == i,
                          onPressed: () {
                            goToPage(i);
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
                          name: x.name!(),
                          icon: x.icon!,
                          isActive: false,
                          onPressed: () {
                            Navigator.of(context).pushNamed(x.route);
                          },
                        ));
                  })
                  .values
                  .toList()),
            ],
          ),
        ),
        onWillPop: () async {
          if (currentIndex != 0) {
            goToPage(0);
            return false;
          }

          if (currentIndex == 0 && (ModalRoute.of(context)?.isFirst ?? false)) {
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            return true;
          }

          return !await Navigator.of(context).maybePop();
        });
  }
}
