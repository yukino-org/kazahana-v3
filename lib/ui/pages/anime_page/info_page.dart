import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:utilx/utilities/locale.dart';
import './shared_props.dart';
import '../../../config/defaults.dart';
import '../../../modules/app/state.dart';
import '../../../modules/helpers/assets.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/trackers/trackers.dart';
import '../../../modules/translator/translator.dart';
import '../../../modules/utils/utils.dart';
import '../../components/preferred_size_wrapper.dart';
import '../../components/size_aware_builder.dart';
import '../../components/toggleable_slide_widget.dart';
import '../../components/trackers/trackers_tile.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({
    required this.props,
    required this.refresh,
    required this.changeLanguage,
    final Key? key,
  }) : super(key: key);

  final SharedProps props;
  final void Function() refresh;
  final void Function(Locale) changeLanguage;

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final int maxChunkLength = AppState.isDesktop ? 100 : 30;

  ScrollDirection? lastScrollDirection;
  final ValueNotifier<bool> showFloatingButton = ValueNotifier<bool>(true);
  late AnimationController floatingButtonController;

  @override
  void initState() {
    super.initState();

    floatingButtonController = AnimationController(
      vsync: this,
      duration: Defaults.animationsNormal,
    );
  }

  @override
  void dispose() {
    showFloatingButton.dispose();
    floatingButtonController.dispose();

    super.dispose();
  }

  Future<void> showLanguageDialog() async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (
        final BuildContext context,
        final Animation<double> a1,
        final Animation<double> a2,
      ) =>
          SafeArea(
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: remToPx(0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: remToPx(1.1),
                  ),
                  child: Text(
                    Translator.t.chooseLanguage(),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                SizedBox(
                  height: remToPx(0.3),
                ),
                ...widget.props.info!.availableLocales
                    .map(
                      (final Locale x) => Material(
                        type: MaterialType.transparency,
                        child: RadioListTile<Locale>(
                          title: Text(x.toString()),
                          value: x,
                          groupValue: widget.props.info!.locale,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (final Locale? val) async {
                            if (val != null &&
                                val != widget.props.info!.locale) {
                              widget.changeLanguage(val);
                            }

                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    )
                    .toList(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: remToPx(0.7),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: remToPx(0.6),
                          vertical: remToPx(0.3),
                        ),
                        child: Text(
                          Translator.t.close(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    super.build(context);

    return SizeAwareBuilder(
      builder: (
        final BuildContext context,
        final ResponsiveSizeInfo rSize,
      ) {
        final double paddingHorizontal = remToPx(rSize.isMd ? 3 : 1.25);

        return NotificationListener<ScrollNotification>(
          onNotification: (final ScrollNotification notification) {
            if (notification is UserScrollNotification) {
              showFloatingButton.value =
                  notification.direction != ScrollDirection.reverse &&
                      lastScrollDirection != ScrollDirection.reverse;

              if (notification.direction == ScrollDirection.forward ||
                  notification.direction == ScrollDirection.reverse) {
                lastScrollDirection = notification.direction;
              }
            }

            return false;
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: PreferredSizeWrapper(
              builder: (
                final BuildContext context,
                final PreferredSizeWidget child,
              ) =>
                  ValueListenableBuilder<bool>(
                valueListenable: showFloatingButton,
                builder: (
                  final BuildContext context,
                  final bool showFloatingButton,
                  final Widget? child,
                ) =>
                    ToggleableSlideWidget(
                  controller: floatingButtonController,
                  visible: showFloatingButton,
                  curve: Curves.easeInOut,
                  offsetBegin: Offset.zero,
                  offsetEnd: const Offset(0, -1),
                  child: child!,
                ),
                child: child,
              ),
              child: AppBar(
                backgroundColor:
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
                elevation: 0,
                iconTheme: IconTheme.of(context).copyWith(
                  color: Theme.of(context).textTheme.headline6?.color,
                ),
                actions: <Widget>[
                  IconButton(
                    onPressed: widget.refresh,
                    tooltip: Translator.t.refetch(),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            body: DefaultTabController(
              length: tabCount,
              child: NestedScrollView(
                headerSliverBuilder: (
                  final BuildContext context,
                  final bool innerBoxIsScrolled,
                ) =>
                    <Widget>[
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: paddingHorizontal,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate.fixed(
                        <Widget>[
                          const SizedBox(
                            height: kToolbarHeight,
                          ),
                          _Hero(props: widget.props),
                          SizedBox(
                            height: remToPx(1.5),
                          ),
                          TrackersTile(
                            title: widget.props.info!.title,
                            plugin: widget.props.extractor!.id,
                            providers: Trackers.anime,
                          ),
                          SizedBox(
                            height: remToPx(1.5),
                          ),
                          Text(
                            Translator.t.episodes(),
                            style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  ?.fontSize,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  ?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (tabCount > 1)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: paddingHorizontal,
                      ),
                      sliver: SliverAppBar(
                        primary: false,
                        pinned: true,
                        floating: true,
                        automaticallyImplyLeading: false,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        titleSpacing: 0,
                        centerTitle: true,
                        title: ScrollConfiguration(
                          behavior: MiceScrollBehavior(),
                          child: TabBar(
                            isScrollable: true,
                            tabs: List<Widget>.generate(
                              tabCount,
                              (final int i) {
                                final int start = i * maxChunkLength;
                                return Tab(
                                  text: '$start - ${start + maxChunkLength}',
                                );
                              },
                            ),
                            labelColor:
                                Theme.of(context).textTheme.bodyText1?.color,
                            indicatorColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                ],
                body: TabBarView(
                  children: List<Widget>.generate(
                    tabCount,
                    (final int i) {
                      final int start = i * maxChunkLength;
                      final int totalLength =
                          widget.props.info!.sortedEpisodes.length;
                      final int end = start + maxChunkLength;
                      final int extra =
                          end > totalLength ? end - totalLength : 0;

                      return Builder(
                        builder: (final BuildContext context) => _Episodes(
                          start: start,
                          end: end - extra,
                          padding: EdgeInsets.symmetric(
                            horizontal: paddingHorizontal,
                          ),
                          props: widget.props,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            floatingActionButton: ValueListenableBuilder<bool>(
              valueListenable: showFloatingButton,
              builder: (
                final BuildContext context,
                final bool showFloatingButton,
                final Widget? child,
              ) =>
                  ToggleableSlideWidget(
                controller: floatingButtonController,
                visible: showFloatingButton,
                curve: Curves.easeInOut,
                offsetBegin: Offset.zero,
                offsetEnd: const Offset(0, 1.5),
                child: child!,
              ),
              child: FloatingActionButton.extended(
                icon: const Icon(Icons.language),
                label: Text(Translator.t.language()),
                onPressed: () {
                  showLanguageDialog();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  int get tabCount =>
      (widget.props.info!.sortedEpisodes.length / maxChunkLength).ceil();
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.props,
    final Key? key,
  }) : super(key: key);

  final SharedProps props;

  @override
  Widget build(final BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    final Widget image = props.info!.thumbnail != null
        ? Image.network(
            props.info!.thumbnail!.url,
            headers: props.info!.thumbnail!.headers,
            width: width > ResponsiveSizes.md ? (15 / 100) * width : remToPx(7),
          )
        : Image.asset(
            Assets.placeholderImageFromContext(context),
            width: width > ResponsiveSizes.md ? (15 / 100) * width : remToPx(7),
          );

    final Widget left = ClipRRect(
      borderRadius: BorderRadius.circular(remToPx(0.5)),
      child: image,
    );

    final Widget right = Column(
      children: <Widget>[
        Text(
          props.info!.title,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.headline4?.fontSize,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          props.extractor!.name,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: Theme.of(context).textTheme.headline6?.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    if (width > ResponsiveSizes.md) {
      return Row(
        children: <Widget>[
          left,
          SizedBox(
            width: remToPx(1),
          ),
          Expanded(child: right),
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          left,
          SizedBox(
            height: remToPx(1),
          ),
          right,
        ],
      );
    }
  }
}

class _Episodes extends StatelessWidget {
  const _Episodes({
    required final this.start,
    required final this.end,
    required final this.padding,
    required final this.props,
    final Key? key,
  }) : super(key: key);

  final int start;
  final int end;
  final EdgeInsets padding;
  final SharedProps props;

  @override
  Widget build(final BuildContext context) => MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: ListView(
          padding: padding,
          children: ListUtils.chunk<Widget>(
            props.info!.sortedEpisodes
                .sublist(
                  start,
                  end,
                )
                .asMap()
                .map(
                  (
                    final int k,
                    final EpisodeInfo x,
                  ) =>
                      MapEntry<int, Widget>(
                    k,
                    Expanded(
                      child: Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            4,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: remToPx(0.4),
                              vertical: remToPx(0.3),
                            ),
                            child: RichText(
                              text: TextSpan(
                                children: <InlineSpan>[
                                  TextSpan(
                                    text: '${Translator.t.episode()} ',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.subtitle2,
                                  ),
                                  TextSpan(
                                    text: x.episode.padLeft(
                                      2,
                                      '0',
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.subtitle2?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onTap: () async {
                            props.setEpisode(start + k);
                            await props.goToPage(Pages.player);
                          },
                        ),
                      ),
                    ),
                  ),
                )
                .values
                .toList(),
            MediaQuery.of(context).size.width ~/ remToPx(8),
            const Expanded(
              child: SizedBox.shrink(),
            ),
          )
              .map(
                (final List<Widget> x) => Row(
                  children: x,
                ),
              )
              .toList(),
        ),
      );
}
