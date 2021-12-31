import 'package:flutter/material.dart';
import '../../../config/defaults.dart';
import '../../../modules/app/state.dart';
import '../../../modules/helpers/deeplink.dart';
import '../../../modules/helpers/protocol_handler.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/state/hooks.dart';
import '../../components/bar_item.dart';
import '../../components/bottom_bar.dart';
import '../../components/side_bar.dart';
import '../../router.dart';

class StackPage {
  const StackPage(this.index, this.r);

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

class _PageState extends State<Page> with HooksMixin {
  late int currentIndex;
  late PageController controller;

  final List<String> stackRoutes = <String>[
    RouteNames.home,
    RouteNames.search,
    RouteNames.store,
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

  int? getIndexOfRoute(final String route) => stack.indexWhere(
        (final StackPage x) => x.r.route == RouteManager.getOnlyRoute(route),
      );

  @override
  void initState() {
    super.initState();

    currentIndex = (RouteManager.keeper.currentRoute != null
            ? getIndexOfRoute(RouteManager.keeper.currentRoute!.settings.name!)
            : null) ??
        0;
    controller = PageController(initialPage: currentIndex);

    onReady(() async {
      final String? link = await Deeplink.getInitialLink();
      if (link != null) {
        ProtocolHandler.handle(link);
      }

      Deeplink.hasHandledInitialLink = true;
      Deeplink.listen();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    hookState.markReady();
  }

  Future<void> goToPage(final int page) async {
    if (controller.hasClients) {
      await controller.animateToPage(
        page,
        duration: Defaults.animationsNormal,
        curve: Curves.easeInOut,
      );
    }
  }

  Widget applySideIfSupported(final Widget body, final List<BarItem> items) {
    if (AppState.isDesktop) {
      return Stack(
        children: <Widget>[
          Positioned.fill(
            left: remToPx(3),
            child: body,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: SideBar(items: items),
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

    return Scaffold(
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
            children:
                stack.map((final StackPage x) => x.r.builder(context)).toList(),
          ),
          barItems,
        ),
      ),
      bottomNavigationBar: AppState.isMobile
          ? BottomBar(
              items: barItems,
            )
          : const SizedBox.shrink(),
    );
  }
}
