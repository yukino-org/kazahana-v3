import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../../components/bar_item.dart';
import '../../components/bottom_bar.dart' as bottom_bar;
import '../../components/side_bar.dart' as side_bar;
import '../../plugins/helpers/ui.dart';
import '../../plugins/router.dart';
import '../../plugins/state.dart';

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

  final List<String> stackRoutes = <String>[
    RouteNames.home,
    RouteNames.search,
    RouteNames.trackers,
  ];

  late final List<StackPage> stack = stackRoutes
      .asMap()
      .map(
        (final int i, final String x) =>
            MapEntry<int, StackPage>(i, StackPage(i, RouteManager.routes[x]!)),
      )
      .values
      .toList();

  late final List<RouteInfo> routes = RouteManager.labeledRoutes
      .where((final RouteInfo x) => !stackRoutes.contains(x.route))
      .toList();

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

    Future<void>.delayed(Duration.zero, () {
      if (AppState.afterInitialRoute != null) {
        Navigator.of(context).pushNamed(AppState.afterInitialRoute!);
        AppState.afterInitialRoute = null;
      }
    });
  }

  void goToPage(final int page) => controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );

  Widget applySideIfSupported(final Widget body, final List<BarItem> items) {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      return Stack(
        children: <Widget>[
          Positioned.fill(
            left: remToPx(2),
            child: body,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: side_bar.SideBar(items: items),
          ),
        ],
      );
    }

    return body;
  }

  @override
  Widget build(final BuildContext context) {
    final List<BarItem> barItems = <BarItem>[
      ...stack.map(
        (final StackPage x) => BarItem(
          name: x.r.name!(),
          icon: x.r.icon!,
          isActive: currentIndex == x.index,
          onPressed: () {
            goToPage(x.index);
          },
        ),
      ),
      ...routes.map(
        (final RouteInfo x) => BarItem(
          name: x.name!(),
          icon: x.icon!,
          isActive: false,
          onPressed: () {
            Navigator.of(context).pushNamed(x.route);
          },
        ),
      ),
    ];

    return WillPopScope(
      child: Scaffold(
        body: SafeArea(
          child: applySideIfSupported(
            PageView(
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
            barItems,
          ),
        ),
        bottomNavigationBar: Platform.isAndroid || Platform.isIOS
            ? bottom_bar.BottomBar(
                items: barItems,
              )
            : const SizedBox.shrink(),
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
}
