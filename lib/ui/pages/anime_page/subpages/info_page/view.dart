import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:utilx/utilities/locale.dart';
import './widgets/episodes.dart';
import './widgets/hero.dart';
import '../../../../../config/defaults.dart';
import '../../../../../modules/app/state.dart';
import '../../../../../modules/helpers/ui.dart';
import '../../../../../modules/trackers/trackers.dart';
import '../../../../../modules/translator/translator.dart';
import '../../../../components/preferred_size_wrapper.dart';
import '../../../../components/size_aware_builder.dart';
import '../../../../components/toggleable_slide_widget.dart';
import '../../../../components/trackers/trackers_tile.dart';
import '../../controller.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({
    required final this.controller,
    final Key? key,
  }) : super(key: key);

  final AnimePageController controller;

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
                ...widget.controller.info.value!.availableLocales
                    .map(
                      (final Locale x) => Material(
                        type: MaterialType.transparency,
                        child: RadioListTile<Locale>(
                          title: Text(x.toString()),
                          value: x,
                          groupValue: widget.controller.info.value!.locale,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (final Locale? val) async {
                            if (val != null &&
                                val != widget.controller.info.value!.locale) {
                              widget.controller.locale = val;
                              widget.controller.getInfo(removeCache: true);
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
        final ResponsiveSize size,
      ) {
        final double paddingHorizontal = remToPx(size.isMd ? 3 : 1.25);

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
                    onPressed: () async {
                      await widget.controller.getInfo(removeCache: true);
                    },
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
                          AnimeHero(controller: widget.controller),
                          SizedBox(
                            height: remToPx(1.5),
                          ),
                          TrackersTile(
                            title: widget.controller.info.value!.title,
                            plugin: widget.controller.extractor!.id,
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
                          widget.controller.info.value!.sortedEpisodes.length;
                      final int end = start + maxChunkLength;
                      final int extra =
                          end > totalLength ? end - totalLength : 0;

                      return Builder(
                        builder: (final BuildContext context) => Episodes(
                          start: start,
                          end: end - extra,
                          padding: EdgeInsets.symmetric(
                            horizontal: paddingHorizontal,
                          ),
                          controller: widget.controller,
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
      (widget.controller.info.value!.sortedEpisodes.length / maxChunkLength)
          .ceil();
}
