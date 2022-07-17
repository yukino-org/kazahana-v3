import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenka/tenka.dart';
import '../../../../core/exports.dart';
import '../../../../core/kitsu/endpoints/seasonal_trends.dart';
import '../../../components/exports.dart';
import '../provider.dart';
import 'kitsu_slide.dart';

class UnderScoreHomePageBody extends StatelessWidget {
  const UnderScoreHomePageBody({
    final Key? key,
  }) : super(key: key);

  Widget buildOnWaiting(final BuildContext _) => SizedBox(
        height: rem(10),
        child: const Center(child: CircularProgressIndicator()),
      );

  Widget buildCarousel(final StatedValue<List<dynamic>> results) => Padding(
        padding: EdgeInsets.only(bottom: rem(1)),
        child: StatedBuilder(
          results.state,
          waiting: buildOnWaiting,
          processing: buildOnWaiting,
          finished: (final _) => KitsuRow(results.value),
          failed: (final _) => const Text('Error'),
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

  Widget buildTrendsSlideshow(final StatedValue<KitsuSeasonTrendsData> data) =>
      StatedBuilder(
        data.state,
        waiting: buildOnWaiting,
        processing: buildOnWaiting,
        finished: (final BuildContext context) => SizedBox(
          height: rem(20),
          child: Slideshow(
            slideDuration: defaultSlideDuration,
            animationDuration: AnimationDurations.defaultNormalAnimation,
            children: data.value.data
                .map((final KitsuAnime x) => KitsuSlide(x))
                .toList(),
          ),
        ),
        failed: (final _) => const Text('Error'),
      );

  @override
  Widget build(final BuildContext context) {
    final UnderScoreHomePageProvider provider =
        context.watch<UnderScoreHomePageProvider>();

    switch (provider.type) {
      case TenkaType.anime:
        return Column(
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: rem(0.75)),
            buildText(Translator.t.topOngoingMangas(), context: context),
            buildCarousel(provider.topOngoingMangas),
            buildText(Translator.t.mostPopularMangas(), context: context),
            buildCarousel(provider.mostPopularMangas),
          ],
        );
    }
  }

  static const Duration defaultSlideDuration = Duration(seconds: 5);
}
