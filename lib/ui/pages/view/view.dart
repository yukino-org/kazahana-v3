import '../../../core/exports.dart';
import '../../exports.dart';
import 'components/exports.dart';
import 'provider.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({
    required this.mediaId,
    this.media,
    final Key? key,
  }) : super(key: key);

  final int mediaId;
  final AnilistMedia? media;

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController appBarAnimationController;
  bool appBarIsVisible = true;

  @override
  void initState() {
    super.initState();

    appBarAnimationController = AnimationController(
      value: 1,
      vsync: this,
      duration: AnimationDurations.defaultQuickAnimation,
    );
  }

  @override
  void dispose() {
    appBarAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(final BuildContext context) =>
      ChangeNotifierProvider<ViewPageProvider>(
        create: (final _) => ViewPageProvider()
          ..initialize(id: widget.mediaId, media: widget.media),
        child: Consumer<ViewPageProvider>(
          builder: (
            final BuildContext context,
            final ViewPageProvider provider,
            final _,
          ) =>
              NotificationListener<ScrollNotification>(
            onNotification: (final ScrollNotification scrollNotification) {
              final bool isAtTop =
                  scrollNotification.metrics.axis == Axis.vertical &&
                      scrollNotification.metrics.pixels == 0;
              if (isAtTop != appBarIsVisible) {
                appBarIsVisible = !appBarIsVisible;
                appBarAnimationController.animateTo(appBarIsVisible ? 1 : 0);
              }
              return false;
            },
            child: Scaffold(
              appBar: ViewPageAppBar(controller: appBarAnimationController),
              extendBodyBehindAppBar: true,
              body: StatedBuilder(
                provider.media.state,
                waiting: (final _) => const SizedBox.shrink(),
                processing: (final _) => const SizedBox.shrink(),
                finished: (final _) => Padding(
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: const ViewPageBody(),
                ),
                failed: (final _) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );
}
