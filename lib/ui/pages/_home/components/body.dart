import '../../../../core/exports.dart';
import '../../../exports.dart';
import '../provider.dart';

class UnderScoreHomePageBody extends StatelessWidget {
  const UnderScoreHomePageBody({
    super.key,
  });

  Widget buildOnWaiting(final BuildContext context) => SizedBox(
        height: context.r.size(12),
        child: const Center(child: CircularProgressIndicator()),
      );

  Widget buildCarousel({
    required final BuildContext context,
    required final StatedValue<List<AnilistMedia>> results,
  }) =>
      Padding(
        padding: EdgeInsets.only(bottom: context.r.size(1)),
        child: StatedBuilder(
          results.state,
          waiting: buildOnWaiting,
          processing: buildOnWaiting,
          finished: (final _) => AnilistMediaRow(results.value),
          failed: (final _) => Text('Error: ${results.error}'),
        ),
      );

  Widget buildText(
    final String text, {
    required final BuildContext context,
  }) =>
      Padding(
        padding: HorizontalBodyPadding.padding(context)
            .copyWith(bottom: context.r.size(0.5)),
        child: Text(text, style: Theme.of(context).textTheme.titleLarge),
      );

  Widget buildTrendsSlideshow(final StatedValue<List<AnilistMedia>> data) =>
      StatedBuilder(
        data.state,
        waiting: buildOnWaiting,
        processing: buildOnWaiting,
        finished: (final BuildContext context) => SizedBox(
          height: context.r.size(25),
          child: Slideshow(
            slideDuration: defaultSlideDuration,
            animationDuration: AnimationDurations.defaultNormalAnimation,
            children: data.value
                .map((final AnilistMedia x) => AnilistMediaSlide(x))
                .toList(),
          ),
        ),
        failed: (final _) => const Text('Error'),
      );

  Widget buildBody(final BuildContext context) {
    final UnderScoreHomePageProvider provider =
        context.watch<UnderScoreHomePageProvider>();

    switch (provider.type) {
      case TenkaType.anime:
        return Column(
          key: const ValueKey<TenkaType>(TenkaType.anime),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildTrendsSlideshow(provider.trendingAnimes),
            SizedBox(height: context.r.size(0.75)),
            buildText(context.t.topOngoingAnimes(), context: context),
            buildCarousel(
              context: context,
              results: provider.topOngoingAnimes,
            ),
            buildText(context.t.mostPopularAnimes(), context: context),
            buildCarousel(
              context: context,
              results: provider.mostPopularAnimes,
            ),
          ],
        );

      case TenkaType.manga:
        return Column(
          key: const ValueKey<TenkaType>(TenkaType.manga),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildTrendsSlideshow(provider.trendingMangas),
            SizedBox(height: context.r.size(0.75)),
            buildText(context.t.topOngoingMangas(), context: context),
            buildCarousel(
              context: context,
              results: provider.topOngoingMangas,
            ),
            buildText(context.t.mostPopularMangas(), context: context),
            buildCarousel(
              context: context,
              results: provider.mostPopularMangas,
            ),
          ],
        );
    }
  }

  @override
  Widget build(final BuildContext context) => PageTransitionSwitcher(
        duration: AnimationDurations.defaultLongAnimation,
        transitionBuilder: (
          final Widget child,
          final Animation<double> animation,
          final Animation<double> secondaryAnimation,
        ) =>
            SharedAxisTransition(
          transitionType: SharedAxisTransitionType.vertical,
          fillColor: Colors.transparent,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        ),
        layoutBuilder: (final List<Widget> children) =>
            Stack(children: children),
        child: buildBody(context),
      );

  static const Duration defaultSlideDuration = Duration(seconds: 5);
}
