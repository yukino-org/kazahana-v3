import '../../../../core/exports.dart';
import '../../../components/exports.dart';
import '../provider.dart';

class UnderScoreHomePageBody extends StatelessWidget {
  const UnderScoreHomePageBody({
    final Key? key,
  }) : super(key: key);

  Widget buildOnWaiting(final BuildContext _) => SizedBox(
        height: rem(12),
        child: const Center(child: CircularProgressIndicator()),
      );

  Widget buildCarousel(final StatedValue<List<AnilistMedia>> results) =>
      Padding(
        padding: EdgeInsets.only(bottom: rem(1)),
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
        padding: EdgeInsets.only(
          left: rem(0.75),
          right: rem(0.75),
          bottom: rem(0.5),
        ),
        child: Text(text, style: Theme.of(context).textTheme.headline6),
      );

  Widget buildTrendsSlideshow(final StatedValue<List<AnilistMedia>> data) =>
      StatedBuilder(
        data.state,
        waiting: buildOnWaiting,
        processing: buildOnWaiting,
        finished: (final BuildContext context) => SizedBox(
          height: rem(20),
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
            SizedBox(height: rem(0.75)),
            buildText(Translator.t.topOngoingAnimes(), context: context),
            buildCarousel(provider.topOngoingAnimes),
            buildText(Translator.t.mostPopularAnimes(), context: context),
            buildCarousel(provider.mostPopularAnimes),
          ],
        );

      case TenkaType.manga:
        return Column(
          key: const ValueKey<TenkaType>(TenkaType.manga),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildTrendsSlideshow(provider.trendingMangas),
            SizedBox(height: rem(0.75)),
            buildText(Translator.t.topOngoingMangas(), context: context),
            buildCarousel(provider.topOngoingMangas),
            buildText(Translator.t.mostPopularMangas(), context: context),
            buildCarousel(provider.mostPopularMangas),
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
