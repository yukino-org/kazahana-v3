import '../../../../core/exports.dart';

class ViewPageEpisodes extends StatelessWidget {
  const ViewPageEpisodes(
    this.media, {
    super.key,
  });

  final AnilistMedia media;

  @override
  // TODO: do this please sempai
  Widget build(final BuildContext context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      );
}
