import 'package:flutter/material.dart';
import './controller.dart';
import './subpages/info_page/view.dart';
import './subpages/reader_page/view.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/translator/translator.dart';
import '../../components/error_widget.dart';
import '../../components/placeholder_appbar.dart';
import '../../components/reactive_state_builder.dart';
import '../../models/view.dart';

class MangaPage extends StatefulWidget {
  const MangaPage({
    final Key? key,
  }) : super(key: key);

  @override
  _MangaPageState createState() => _MangaPageState();
}

class _MangaPageState extends State<MangaPage>
    with SingleTickerProviderStateMixin {
  final PageController pageController = PageController(
    initialPage: SubPages.home.index,
  );
  late final MangaPageController controller = MangaPageController(
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
    pageController.dispose();
    controller.dispose();

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
          child: View<MangaPageController>(
            controller: controller,
            builder: (
              final BuildContext context,
              final MangaPageController controller,
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
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  InfoPage(controller: controller),
                  Builder(
                    builder: (final BuildContext context) {
                      if (controller.currentChapter == null) {
                        return const SizedBox.shrink();
                      }

                      return ReaderPage(
                        key: ValueKey<String>(
                          'Chapter-${controller.currentChapterIndex}',
                        ),
                        mangaController: controller,
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
