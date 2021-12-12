import 'package:flutter/material.dart';
import '../../../../../../modules/app/state.dart';
import '../../../../../../modules/database/database.dart';
import '../../../../../../modules/helpers/ui.dart';
import '../../../../../../modules/translator/translator.dart';
import '../../../../settings_page/setting_labels/manga.dart';
import '../controller.dart';

class MangaReaderAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MangaReaderAppBar({
    required final this.controller,
    final Key? key,
  }) : super(key: key);

  final ReaderPageController controller;

  @override
  State<MangaReaderAppBar> createState() => _MangaReaderAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MangaReaderAppBarState extends State<MangaReaderAppBar> {
  Future<void> showOptions() async {
    await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(remToPx(0.5)),
          topRight: Radius.circular(remToPx(0.5)),
        ),
      ),
      context: context,
      builder: (final BuildContext context) => SafeArea(
        child: StatefulBuilder(
          builder: (
            final BuildContext context,
            final StateSetter setState,
          ) =>
              Padding(
            padding: EdgeInsets.symmetric(vertical: remToPx(0.25)),
            child: Wrap(
              children: <Widget>[
                Column(
                  children: getSettingsManga(
                    context,
                    AppState.settings.value,
                    () async {
                      await SettingsBox.save(AppState.settings.value);

                      if (!mounted) return;
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    widget.controller.mangaController.reassemble();
  }

  @override
  Widget build(final BuildContext context) => AppBar(
        elevation: 0,
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: Translator.t.back(),
          onPressed: widget.controller.mangaController.goHome,
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await widget.controller.setFullscreen(
                enabled: !AppState.settings.value.manga.fullscreen,
              );
            },
            icon: Icon(
              AppState.settings.value.manga.fullscreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
            ),
          ),
          IconButton(
            onPressed: showOptions,
            icon: const Icon(Icons.more_vert),
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.controller.mangaController.info.value!.title,
              style: Theme.of(context).textTheme.headline6,
            ),
            RichText(
              text: TextSpan(
                children: <InlineSpan>[
                  if (widget
                          .controller.mangaController.currentChapter!.volume !=
                      null)
                    TextSpan(
                      text:
                          '${Translator.t.vol()} ${widget.controller.mangaController.currentChapter!.volume} ',
                    ),
                  TextSpan(
                    text:
                        '${Translator.t.ch()} ${widget.controller.mangaController.currentChapter!.chapter}',
                  ),
                  if (widget.controller.mangaController.currentChapter!.title !=
                      null)
                    TextSpan(
                      text:
                          ' - ${widget.controller.mangaController.currentChapter!.title}',
                    ),
                ],
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
          ],
        ),
      );
}
