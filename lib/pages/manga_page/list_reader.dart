import 'package:flutter/material.dart';
import '../../core/utils.dart' as utils;
import '../../core/extractor/manga/model.dart' as manga_model;
import '../../plugins/translator/translator.dart';
import '../../plugins/state.dart' show AppState;
import '../../plugins/database/schemas/settings/settings.dart' show MangaMode;
import '../../components/full_screen_image.dart';
import '../settings_page/setting_radio.dart';

class ListReader extends StatefulWidget {
  final manga_model.MangaInfo info;
  final manga_model.ChapterInfo chapter;
  final List<manga_model.PageInfo> pages;

  final void Function() onPop;
  final void Function() previousChapter;
  final void Function() nextChapter;

  const ListReader({
    Key? key,
    required this.info,
    required this.chapter,
    required this.pages,
    required this.onPop,
    required this.previousChapter,
    required this.nextChapter,
  }) : super(key: key);

  @override
  ListReaderState createState() => ListReaderState();
}

class ListReaderState extends State<ListReader> {
  void showOptions() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(utils.remToPx(0.5)),
          topRight: Radius.circular(utils.remToPx(0.5)),
        ),
      ),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: utils.remToPx(0.25)),
              child: Wrap(
                children: [
                  Column(
                    children: [
                      SettingRadio(
                        title: Translator.t.mangaReaderMode(),
                        icon: Icons.pageview,
                        value: AppState.settings.current.mangaReaderMode,
                        labels: {
                          MangaMode.list: Translator.t.list(),
                          MangaMode.page: Translator.t.page(),
                        },
                        onChanged: (MangaMode val) async {
                          AppState.settings.current.mangaReaderMode = val;
                          await AppState.settings.current.save();
                          AppState.settings.modify(AppState.settings.current);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onPop,
        ),
        actions: [
          IconButton(
            onPressed: widget.previousChapter,
            icon: const Icon(Icons.first_page),
          ),
          IconButton(
            onPressed: widget.nextChapter,
            icon: const Icon(Icons.last_page),
          ),
          IconButton(
            onPressed: () {
              showOptions();
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.info.title,
            ),
            Text(
              '${widget.chapter.volume != null ? '${Translator.t.vol()} ${widget.chapter.volume} ' : ''}${Translator.t.ch()} ${widget.chapter.chapter} ${widget.chapter.title != null ? '- ${widget.chapter.title}' : ''}',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.subtitle2?.fontSize,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).cardColor,
      ),
      body: widget.pages.isEmpty
          ? Center(
              child: Text(Translator.t.noPagesFound()),
            )
          : ListView.builder(
              itemCount: widget.pages.length,
              itemBuilder: (context, index) {
                final page = widget.pages[index];

                return Image.network(
                  page.url,
                  headers: page.headers,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return Stack(
                        children: [
                          child,
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return FullScreenInteractiveImage(
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return SizedBox(
                      height: utils.remToPx(20),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
