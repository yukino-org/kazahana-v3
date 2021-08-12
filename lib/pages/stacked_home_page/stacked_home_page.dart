import 'package:flutter/material.dart';
import '../../components/bottom_bar.dart' as bottom_bar;
import '../../plugins/router.dart';

class StackPage {
  StackPage(this.index, this.r);

  final RouteInfo r;
  final int index;
}

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  late int currentIndex;
  late PageController controller;

  final List<StackPage> stack = <RouteInfo>[
    RouteManager.routes[RouteNames.home]!,
    RouteManager.routes[RouteNames.search]!,
  ]
      .asMap()
      .map(
        (final int i, final RouteInfo x) =>
            MapEntry<int, StackPage>(i, StackPage(i, x)),
      )
      .values
      .toList();
  final List<RouteInfo> routes = <RouteInfo>[
    RouteManager.routes[RouteNames.settings]!,
  ];

  int? getIndexOfRoute(final String route) =>
      stack.indexWhere((final StackPage x) => x.r.route == route);

  @override
  void initState() {
    super.initState();

    currentIndex = (RouteManager.keeper.currentRoute != null
            ? getIndexOfRoute(RouteManager.keeper.currentRoute!.settings.name!)
            : null) ??
        0;
    controller = PageController(initialPage: currentIndex);
  }

  void goToPage(final int page) => controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );

  @override
  Widget build(final BuildContext context) => WillPopScope(
        child: Scaffold(
          body: SafeArea(
            child: PageView(
              onPageChanged: (final int page) {
                setState(() {
                  currentIndex = page;
                });
              },
              physics: const NeverScrollableScrollPhysics(),
              controller: controller,
              children: stack
                  .map((final StackPage x) => x.r.builder(context))
                  .toList(),
            ),
          ),
          bottomNavigationBar: bottom_bar.BottomBar(
            initialIndex: currentIndex,
            items: <bottom_bar.BottomBarItem>[
              ...stack.map(
                (final StackPage x) => bottom_bar.BottomBarItem(
                  name: x.r.name!(),
                  icon: x.r.icon!,
                  isActive: currentIndex == x.index,
                  onPressed: () {
                    goToPage(x.index);
                  },
                ),
              ),
              ...routes.map(
                (final RouteInfo x) => bottom_bar.BottomBarItem(
                  name: x.name!(),
                  icon: x.icon!,
                  isActive: false,
                  onPressed: () {
                    Navigator.of(context).pushNamed(x.route);
                  },
                ),
              ),
            ],
          ),
        ),
        onWillPop: () async {
          final int homeIndex = stack[getIndexOfRoute(RouteNames.home)!].index;
          if (currentIndex != homeIndex) {
            goToPage(homeIndex);
            return false;
          }

          Navigator.of(context).pop();
          return true;
        },
      );
}
