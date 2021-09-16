import 'package:flutter/material.dart';
import './media_list.dart';
import '../../../../core/models/page_args/anilist_page.dart' as anilist_page;
import '../../../../core/trackers/anilist/anilist.dart' as anilist;
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
  StatefulHolder<anilist.UserInfo?> user =
      StatefulHolder<anilist.UserInfo?>(null);

  final List<Tab> tabs = anilist.MediaListStatus.values
      .map(
        (final anilist.MediaListStatus status) => Tab(
          text: StringUtils.capitalize(status.status),
        ),
      )
      .toList();

  late final anilist_page.PageArguments args;

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
      args = anilist_page.PageArguments.fromJson(
        ParsedRouteInfo.fromSettings(ModalRoute.of(context)!.settings).params,
      );

      final anilist.UserInfo _user = await anilist.getUserInfo();
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

  Widget getProfile(final anilist.UserInfo user) {
    final double width = MediaQuery.of(context).size.width;

    final Widget left = Material(
      shape: const CircleBorder(),
      elevation: 5,
      child: CircleAvatar(
        radius: remToPx(2.5),
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(
          user.avatarMedium,
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

    final Widget right = TextButton(
      style: TextButton.styleFrom(
        primary: Colors.white,
        backgroundColor: Colors.red[400],
        elevation: 2,
      ),
      onPressed: () async {
        await anilist.AnilistManager.auth.deleteToken();
        Navigator.of(context).pop();
      },
      child: Text(
        Translator.t.logOut(),
        style: Theme.of(context).textTheme.bodyText1?.copyWith(
              color: Colors.white,
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
                    type: args.type,
                    status: anilist.MediaListStatus.values[index],
                  ),
                ),
              ),
            )
          : loader,
    );
  }
}
