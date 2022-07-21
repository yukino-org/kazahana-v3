import '../../../../core/exports.dart';
import '../provider.dart';
import 'episodes.dart';
import 'hero.dart';
import 'overview.dart';

enum _ViewPageTabs {
  overview,
  episodes,
}

extension on _ViewPageTabs {
  String get titleCase {
    switch (this) {
      case _ViewPageTabs.overview:
        return Translator.t.overview();

      case _ViewPageTabs.episodes:
        return Translator.t.episodes();
    }
  }
}

class ViewPageBody extends StatefulWidget {
  const ViewPageBody({
    final Key? key,
  }) : super(key: key);

  @override
  State<ViewPageBody> createState() => _ViewPageBodyState();
}

class _ViewPageBodyState extends State<ViewPageBody>
    with SingleTickerProviderStateMixin {
  final List<_ViewPageTabs> tabs = <_ViewPageTabs>[
    _ViewPageTabs.overview,
    _ViewPageTabs.episodes,
  ];

  late final TabController tabController;
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: tabs.length, vsync: this);
    scrollController = ScrollController()
      ..addListener(() {
        if (mounted && scrollController.hasClients) {
          final ViewPageViewProvider provider =
              context.read<ViewPageViewProvider>();

          provider.setFloatingAppBarVisibility(
            visible: scrollController.position.pixels < 50,
          );
        }
      });
  }

  @override
  void dispose() {
    tabController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final ViewPageProvider provider = context.watch<ViewPageProvider>();
    final AnilistMedia media = provider.media.value;

    return NestedScrollView(
      controller: scrollController,
      floatHeaderSlivers: true,
      headerSliverBuilder:
          (final BuildContext context, final bool innerBoxIsScrolled) =>
              <Widget>[
        SliverList(
          delegate: SliverChildListDelegate.fixed(
            <Widget>[
              ViewPageHero(media),
              SizedBox(height: rem(0.75)),
              const Divider(height: 0, thickness: 0),
            ],
          ),
        ),
        SliverOverlapAbsorber(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          sliver: SliverPersistentHeader(
            pinned: true,
            floating: true,
            delegate: _SliverTabBarHeaderDelegate(
              TabBar(
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelStyle: Theme.of(context).textTheme.bodyLarge,
                controller: tabController,
                tabs: tabs
                    .asMap()
                    .map(
                      (final int i, final _ViewPageTabs x) =>
                          MapEntry<int, Widget>(i, Tab(text: x.titleCase)),
                    )
                    .values
                    .toList(),
              ),
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: tabController,
        children: <Widget>[
          Builder(builder: (final _) => ViewPageOverview(media)),
          Builder(builder: (final _) => ViewPageEpisodes(media)),
        ],
      ),
    );
  }
}

class _SliverTabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _SliverTabBarHeaderDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  Widget build(final BuildContext context, final _, final __) => DecoratedBox(
        decoration:
            BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        child: tabBar,
      );

  @override
  bool shouldRebuild(final _SliverTabBarHeaderDelegate oldDelegate) => false;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;
}
