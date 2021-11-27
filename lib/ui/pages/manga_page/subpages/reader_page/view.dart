import 'package:flutter/material.dart';
import './controller.dart';
import './kinds/list_reader.dart';
import './kinds/page_reader/view.dart';
import '../../../../../modules/database/schemas/settings/settings.dart';
import '../../../../../modules/helpers/ui.dart';
import '../../../../../modules/translator/translator.dart';
import '../../../../components/error_widget.dart';
import '../../../../components/reactive_state_builder.dart';
import '../../../../models/view.dart';
import '../../controller.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({
    required final this.mangaController,
    final Key? key,
  }) : super(key: key);

  final MangaPageController mangaController;

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  late final ReaderPageController controller = ReaderPageController(
    mangaController: widget.mangaController,
  );

  @override
  void initState() {
    super.initState();

    controller.setup();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    controller.ready();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => View<ReaderPageController>(
        controller: controller,
        builder: (
          final BuildContext context,
          final ReaderPageController controller,
        ) =>
            ReactiveStateBuilder(
          state: controller.pages.state,
          onResolving: (final BuildContext context) => const Center(
            child: CircularProgressIndicator(),
          ),
          onResolved: (final BuildContext context) {
            switch (controller.mangaMode) {
              case MangaMode.page:
                return PageReader(controller: controller);

              case MangaMode.list:
                return ListReader(controller: controller);
            }
          },
          onFailed: (final BuildContext context) => Padding(
            padding: EdgeInsets.symmetric(
              horizontal: remToPx(1.5),
            ),
            child: Center(
              child: KawaiiErrorWidget.fromErrorInfo(
                message: Translator.t.failedToGetResults(),
                error: controller.pages.error,
              ),
            ),
          ),
        ),
      );
}
