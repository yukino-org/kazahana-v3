import 'package:flutter/material.dart';
import './anime_list/anime_list.dart';
import '../../../../core/models/page_args/myanimelist_page.dart'
    as myanimelist_page;
import '../../../../core/trackers/myanimelist/myanimelist.dart' as myanimelist;
import '../../../../plugins/helpers/assets.dart';
import '../../../../plugins/helpers/stateful_holder.dart';
import '../../../../plugins/helpers/ui.dart';
import '../../../../plugins/helpers/utils/string.dart';
import '../../../../plugins/router.dart';
import '../../../../plugins/translator/translator.dart';

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> with SingleTickerProviderStateMixin {
  StatefulHolder<myanimelist.UserInfo?> user =
      StatefulHolder<myanimelist.UserInfo?>(null);

  final List<Tab> tabs = myanimelist.AnimeListStatus.values
      .map(
        (final myanimelist.AnimeListStatus status) => Tab(
          text: StringUtils.capitalize(status.pretty),
        ),
      )
      .toList();

  late final myanimelist_page.PageArguments args;

  final Duration animationDuration = const Duration(milliseconds: 300);
  late final TabController tabController;
  late final PageController pageController;

  final Widget loader = const Center(
    child: CircularProgressIndicator(),
  );

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(Duration.zero, () async {
      args = myanimelist_page.PageArguments.fromJson(
        ParsedRouteInfo.fromSettings(ModalRoute.of(context)!.settings).params,
      );

      final myanimelist.UserInfo _user = await myanimelist.getUserInfo();
      if (mounted) {
        setState(() {
          user.resolve(_user);
        });
      }
    });

    tabController = TabController(
      length: tabs.length,
      vsync: this,
    );

    pageController = PageController(
      initialPage: tabController.index,
    );

    tabController.addListener(() {
      if (tabController.index != pageController.page) {
        pageController.animateToPage(
          tabController.index,
          duration: animationDuration,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Widget getProfile(final myanimelist.UserInfo user) {
    final double width = MediaQuery.of(context).size.width;

    final Widget left = Material(
      shape: const CircleBorder(),
      elevation: 5,
      child: SizedBox(
        width: remToPx(5),
        height: remToPx(5),
        child: Padding(
          padding: EdgeInsets.all(remToPx(0.6)),
          child: Image.asset(
            Assets.myAnimeListLogo,
            width: remToPx(4.4),
          ),
        ),
      ),
    );

    final Widget mid = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          user.name,
          style: Theme.of(context).textTheme.headline4?.copyWith(
                color: Theme.of(context).textTheme.overline?.color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          'ID: ${user.id}',
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );

    final Widget right = Material(
      type: MaterialType.transparency,
      elevation: 2,
      color: Colors.white,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(remToPx(0.2)),
        ),
        child: InkWell(
          onTap: () async {
            await myanimelist.MyAnimeListManager.auth.deleteToken();

            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: remToPx(0.5),
              vertical: remToPx(0.2),
            ),
            child: Text(
              Translator.t.logOut(),
              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ),
      ),
    );

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
        title: Text(Translator.t.anilist()),
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
                    child: getProfile(user.value!),
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
                      MediaList(
                    status: myanimelist.AnimeListStatus.values[index],
                  ),
                ),
              ),
            )
          : loader,
    );
  }
}
