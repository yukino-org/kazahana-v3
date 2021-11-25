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

class AnimePage extends StatelessWidget {
  AnimePage({
    final Key? key,
  }) : super(key: key);

  final AnimePageController controller = AnimePageController();

  @override
  Widget build(final BuildContext context) => WillPopScope(
        child: SafeArea(
          child: View<AnimePageController>(
            controller: controller,
            afterReady: (
              final AnimePageController controller,
              final bool done,
            ) async {
              await controller.initController(context);
            },
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
                  if (controller.episode != null)
                    WatchPage(
                      key: ValueKey<String>(
                        'Episode-${controller.currentEpisodeIndex}',
                      ),
                      animeController: controller,
                    )
                  else
                    Scaffold(
                      appBar: AppBar(),
                      body: Text('poop'),
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
        onWillPop: () async {
          if (controller.pageController.page?.toInt() != SubPages.home.index) {
            await controller.goToPage(SubPages.home);
            controller.currentEpisodeIndex = null;
            controller.rebuild();
            return false;
          }

          Navigator.of(context).pop();
          return true;
        },
      );
}
