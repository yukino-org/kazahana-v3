import 'package:flutter/material.dart';
import '../../components/bottom_bar.dart' as bottom_bar;
import '../../plugins/router.dart';

class StackPage {
  final RouteInfo r;
  final int index;

  StackPage(this.index, this.r);
}

class Page extends StatefulWidget {
  const Page({Key? key}) : super(key: key);

  @override
  State<Page> createState() => PageState();
}

class PageState extends State<Page> {
  late int currentIndex;
  late PageController controller;

  final List<StackPage> stack = [
    RouteManager.routes[RouteNames.home]!,
    RouteManager.routes[RouteNames.search]!,
  ].asMap().map((i, x) => MapEntry(i, StackPage(i, x))).values.toList();
  final List<RouteInfo> routes = [
    RouteManager.routes[RouteNames.settings]!,
  ];

  int? getIndexOfRoute(String route) =>
      stack.indexWhere((x) => x.r.route == route);

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
              children: stack.map((x) => x.r.builder(context)).toList(),
            ),
          ),
          bottomNavigationBar: bottom_bar.BottomBar(
            initialIndex: currentIndex,
            items: [
              ...(stack.map((x) {
                return bottom_bar.BottomBarItem(
                  name: x.r.name!(),
                  icon: x.r.icon!,
                  isActive: currentIndex == x.index,
                  onPressed: () {
                    goToPage(x.index);
                  },
                );
              })),
              ...(routes.map((x) {
                return bottom_bar.BottomBarItem(
                  name: x.name!(),
                  icon: x.icon!,
                  isActive: false,
                  onPressed: () {
                    Navigator.of(context).pushNamed(x.route);
                  },
                );
              })),
            ],
          ),
        ),
        onWillPop: () async {
          final homeIndex = stack[getIndexOfRoute(RouteNames.home)!].index;
          if (currentIndex != homeIndex) {
            goToPage(homeIndex);
            return false;
          }

          Navigator.of(context).pop();
          return true;
        });
  }
}
