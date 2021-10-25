import 'package:flutter/material.dart';
import '../../../../plugins/helpers/stateful_holder.dart';
import '../../../../plugins/helpers/ui.dart';

class ProfileTab {
  ProfileTab({
    required final this.getLeft,
    required final this.getMid,
    required final this.getRight,
  });

  final Widget Function(dynamic) getLeft;
  final Widget Function(dynamic) getMid;
  final Widget Function(dynamic, void Function()) getRight;
}

class PageTab {
  PageTab(this.data, this.stringify);

  final dynamic data;
  final String stringify;
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    required final this.title,
    required final this.tabs,
    required final this.profile,
    required final this.getUserInfo,
    required final this.getMediaList,
    final Key? key,
  }) : super(key: key);

  final String Function() title;
  final List<PageTab> tabs;
  final ProfileTab profile;
  final Future<dynamic> Function() getUserInfo;
  final Widget Function(PageTab) getMediaList;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin, DidLoadStater {
  StatefulHolder<dynamic> user = StatefulHolder<dynamic>(null);

  late final List<Tab> tabs = widget.tabs
      .map(
        (final PageTab x) => Tab(
          text: x.stringify,
        ),
      )
      .toList();

  final Duration animationDuration = const Duration(milliseconds: 300);
  late final TabController tabController;
  late final PageController pageController;

  final Widget loader = const Center(
    child: CircularProgressIndicator(),
  );

  @override
  void initState() {
    super.initState();

    tabController = TabController(
      length: tabs.length,
      vsync: this,
    );

    pageController = PageController(
      initialPage: tabController.index,
    );

    tabController.addListener(() {
      if (tabController.index != pageController.page &&
          pageController.hasClients) {
        pageController.animateToPage(
          tabController.index,
          duration: animationDuration,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    doLoadStateIfHasnt();
  }

  @override
  Future<void> load() async {
    final dynamic _user = await widget.getUserInfo();

    if (mounted) {
      setState(() {
        user.resolve(_user);
      });
    }
  }

  Widget getProfile(final dynamic user) {
    final double width = MediaQuery.of(context).size.width;

    final Widget left = widget.profile.getLeft(user);
    final Widget mid = widget.profile.getMid(user);
    final Widget right = widget.profile.getRight(user, () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });

    return width > ResponsiveSizes.md
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              left,
              SizedBox(width: remToPx(2)),
              Expanded(child: mid),
              SizedBox(width: remToPx(2)),
              right,
            ],
          )
        : Column(
            children: <Widget>[
              left,
              SizedBox(height: remToPx(0.5)),
              mid,
              SizedBox(height: remToPx(1)),
              right,
            ],
          );
  }

  @override
  Widget build(final BuildContext context) {
    final bool isLarge = MediaQuery.of(context).size.width > ResponsiveSizes.md;

    final TabBar tabbar = TabBar(
      isScrollable: true,
      controller: tabController,
      tabs: tabs,
      labelColor: Theme.of(context).textTheme.bodyText1?.color,
      indicatorColor: Theme.of(context).primaryColor,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title()),
      ),
      body: user.hasResolved
          ? NestedScrollView(
              headerSliverBuilder:
                  (final BuildContext context, final bool isScrolled) =>
                      <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: remToPx(isLarge ? 3 : 1.25),
                      right: remToPx(isLarge ? 3 : 1.25),
                      top: remToPx(2),
                      bottom: remToPx(isLarge ? 2 : 1),
                    ),
                    child: getProfile(user.value),
                  ),
                ),
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  bottom: PreferredSize(
                    preferredSize: tabbar.preferredSize,
                    child: ScrollConfiguration(
                      behavior: MiceScrollBehavior(),
                      child: tabbar,
                    ),
                  ),
                ),
              ],
              body: Padding(
                padding: EdgeInsets.only(
                  left: remToPx(isLarge ? 3 : 1.25),
                  right: remToPx(isLarge ? 3 : 1.25),
                  top: remToPx(1),
                ),
                child: PageView.builder(
                  controller: pageController,
                  itemCount: tabs.length,
                  itemBuilder: (final BuildContext context, final int index) =>
                      widget.getMediaList(widget.tabs[index]),
                ),
              ),
            )
          : loader,
    );
  }
}
