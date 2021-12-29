import 'package:flutter/material.dart';
import './controller.dart';
import './subpages/info_page/view.dart';
import './subpages/watch_page/view.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/translator/translator.dart';
import '../../components/error_widget.dart';
import '../../components/placeholder_appbar.dart';
import '../../components/reactive_state_builder.dart';
import '../../models/view.dart';

class AnimePage extends StatefulWidget {
  const AnimePage({
    final Key? key,
  }) : super(key: key);

  @override
  _AnimePageState createState() => _AnimePageState();
}

class _AnimePageState extends State<AnimePage> {
  final PageController pageController = PageController(
    initialPage: SubPages.home.index,
  );

  late final AnimePageController controller = AnimePageController(
    pageController: pageController,
  );

  @override
  void initState() {
    super.initState();

    controller.setup().then((final void _) async {
      await controller.onInitState(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    controller.ready();
  }

  @override
  void dispose() {
    controller.dispose();
    pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => WillPopScope(
        onWillPop: () async {
          if (pageController.hasClients &&
              controller.currentPage != SubPages.home) {
            await controller.goHome();
            return false;
          }

          Navigator.of(context).pop();
          return true;
        },
        child: SafeArea(
          child: View<AnimePageController>(
            controller: controller,
            builder: (
              final BuildContext context,
              final AnimePageController controller,
            ) =>
                ReactiveStateBuilder(
              state: controller.info.state,
              onResolving: (final BuildContext context) => Scaffold(
                appBar: const PlaceholderAppBar(),
                body: Center(
                  child: controller.initialized && controller.extractor == null
                      ? KawaiiErrorWidget(
                          message: Translator.t
                              .unknownExtension(controller.args!.plugin),
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
              onResolved: (final BuildContext context) => PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  InfoPage(controller: controller),
                  Builder(
                    builder: (final BuildContext context) {
                      if (controller.currentEpisode == null) {
                        return const SizedBox.shrink();
                      }

                      return WatchPage(
                        key: ValueKey<String>(
                          'Episode-${controller.currentEpisodeIndex}',
                        ),
                        animeController: controller,
                      );
                    },
                  ),
                ],
              ),
              onFailed: (final BuildContext context) => Scaffold(
                appBar: const PlaceholderAppBar(),
                body: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: remToPx(1.5),
                  ),
                  child: Center(
                    child: KawaiiErrorWidget.fromErrorInfo(
                      message: Translator.t.failedToGetResults(),
                      error: controller.info.error,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
