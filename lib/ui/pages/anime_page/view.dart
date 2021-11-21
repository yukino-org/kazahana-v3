import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:utilx/utilities/locale.dart';
import 'package:yukino_app/ui/models/view.dart';
import 'package:yukino_app/ui/pages/anime_page/controller.dart';
import 'subpages/info_page/view.dart';
import './widgets/shared_props.dart';
import 'subpages/watch_page/view.dart';
import '../../../config/defaults.dart';
import '../../../modules/database/database.dart';
import '../../../modules/extensions/extensions.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/state/hooks.dart';
import '../../../modules/state/stateful_holder.dart';
import '../../../modules/translator/translator.dart';
import '../../../modules/utils/utils.dart';
import '../../components/error_widget.dart';
import '../../components/placeholder_appbar.dart';
import '../../components/reactive_state_builder.dart';
import '../../router.dart';

class AnimePage extends StatelessWidget {
  AnimePage({
    final Key? key,
  }) : super(key: key);

  final AnimeViewController controller = AnimeViewController();

  @override
  Widget build(final BuildContext context) => WillPopScope(
        child: SafeArea(
          child: View<AnimeViewController>(
            controller: controller,
            builder: (
              final BuildContext context,
              final AnimeViewController controller,
            ) =>
                ReactiveStateBuilder(
              state: controller.info.state,
              onResolving: (final BuildContext context) => Scaffold(
                appBar: const PlaceholderAppBar(),
                body: Center(
                  child: controller.extractor == null
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
                      props: props,
                      pop: () async {
                        await props.goToPage(Pages.home);
                        props.setEpisode(null);
                      },
                    )
                  else
                    const SizedBox.shrink(),
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
                      error: infoState.value,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        onWillPop: () async {
          if (props.info != null &&
              pageController.page?.toInt() != Pages.home.index) {
            await props.goToPage(Pages.home);
            props.setEpisode(null);
            return false;
          }

          Navigator.of(context).pop();
          return true;
        },
      );
}
