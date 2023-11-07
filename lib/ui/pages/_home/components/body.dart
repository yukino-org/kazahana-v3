import 'package:kazahana/core/exports.dart';
import '../../../exports.dart';
import '../provider.dart';

class UnderScoreHomePageBody extends StatelessWidget {
  const UnderScoreHomePageBody({
    super.key,
  });

  Widget buildOnWaiting(final BuildContext context) => SizedBox(
        height: context.r.scale(12),
        child: const Center(child: CircularProgressIndicator()),
      );

  Widget buildCarousel({
    required final BuildContext context,
    required final StatedValue<List<AnilistMedia>> results,
  }) =>
      Padding(
        padding: EdgeInsets.only(bottom: context.r.scale(1)),
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
            .copyWith(bottom: context.r.scale(0.75, md: 1)),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget buildTrendsSlideshow(final StatedValue<List<AnilistMedia>> data) =>
      StatedBuilder(
        data.state,
        waiting: buildOnWaiting,
        processing: buildOnWaiting,
        finished: (final BuildContext context) => SizedBox(
          height: context.r.scale(25),
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

    return switch (provider.type) {
      TenkaType.anime => Column(
          key: const ValueKey<TenkaType>(TenkaType.anime),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildTrendsSlideshow(provider.trendingAnime),
            SizedBox(height: context.r.scale(2)),
            buildText(context.t.topOngoingAnime, context: context),
            buildCarousel(
              context: context,
              results: provider.topOngoingAnime,
            ),
            SizedBox(height: context.r.scale(1)),
            buildText(context.t.mostPopularAnime, context: context),
            buildCarousel(
              context: context,
              results: provider.mostPopularAnime,
            ),
            SizedBox(height: context.r.scale(1)),
          ],
        ),
      TenkaType.manga => Column(
          key: const ValueKey<TenkaType>(TenkaType.manga),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildTrendsSlideshow(provider.trendingManga),
            SizedBox(height: context.r.scale(2)),
            buildText(context.t.topOngoingManga, context: context),
            buildCarousel(
              context: context,
              results: provider.topOngoingManga,
            ),
            SizedBox(height: context.r.scale(1)),
            buildText(context.t.mostPopularManga, context: context),
            buildCarousel(
              context: context,
              results: provider.mostPopularManga,
            ),
            SizedBox(height: context.r.scale(1)),
          ],
        ),
    };
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
