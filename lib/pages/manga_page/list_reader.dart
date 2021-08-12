import 'package:flutter/material.dart';
import '../../components/full_screen_image.dart';
import '../../core/extractor/manga/model.dart' as manga_model;
import '../../plugins/database/schemas/settings/settings.dart' show MangaMode;
import '../../plugins/helpers/stateful_holder.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/state.dart' show AppState;
import '../../plugins/translator/translator.dart';
import '../settings_page/setting_radio.dart';

class ListReader extends StatefulWidget {
  const ListReader({
    required final this.plugin,
    required final this.info,
    required final this.chapter,
    required final this.pages,
    required final this.onPop,
    required final this.previousChapter,
    required final this.nextChapter,
    final Key? key,
  }) : super(key: key);

  final manga_model.MangaExtractor plugin;
  final manga_model.MangaInfo info;
  final manga_model.ChapterInfo chapter;
  final List<manga_model.PageInfo> pages;

  final void Function() onPop;
  final void Function() previousChapter;
  final void Function() nextChapter;

  @override
  ListReaderState createState() => ListReaderState();
}

class ListReaderState extends State<ListReader> {
  final Widget loader = const CircularProgressIndicator();

  late final Map<manga_model.PageInfo, StatefulHolder<manga_model.ImageInfo?>>
      images = <manga_model.PageInfo, StatefulHolder<manga_model.ImageInfo?>>{};

  Future<void> getPage(final manga_model.PageInfo page) async {
    images[page]!.state = LoadState.resolving;
    final manga_model.ImageInfo image = await widget.plugin.getPage(page);
    setState(() {
      images[page]!.value = image;
      images[page]!.state = LoadState.resolved;
    });
  }

  void showOptions() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(remToPx(0.5)),
          topRight: Radius.circular(remToPx(0.5)),
        ),
      ),
      context: context,
      builder: (final BuildContext context) => StatefulBuilder(
        builder: (
          final BuildContext context,
          final StateSetter setState,
        ) =>
            Padding(
          padding: EdgeInsets.symmetric(vertical: remToPx(0.25)),
          child: Wrap(
            children: <Widget>[
              Column(
                children: <Widget>[
                  SettingRadio<MangaMode>(
                    title: Translator.t.mangaReaderMode(),
                    icon: Icons.pageview,
                    value: AppState.settings.current.mangaReaderMode,
                    labels: <MangaMode, String>{
                      MangaMode.list: Translator.t.list(),
                      MangaMode.page: Translator.t.page(),
                    },
                    onChanged: (final MangaMode val) async {
                      AppState.settings.current.mangaReaderMode = val;
                      await AppState.settings.current.save();
                      AppState.settings.modify(AppState.settings.current);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onPop,
          ),
          actions: <Widget>[
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
            children: <Widget>[
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
                itemBuilder: (final BuildContext context, final int index) {
                  final manga_model.PageInfo page = widget.pages[index];

                  if (images[page] == null) {
                    images[page] = StatefulHolder<manga_model.ImageInfo?>(null);
                  }

                  if (!images[page]!.hasValue) {
                    if (!images[page]!.isResolving) {
                      getPage(page);
                    }

                    return loader;
                  }

                  final manga_model.ImageInfo image = images[page]!.value!;
                  return Image.network(
                    image.url,
                    headers: image.headers,
                    loadingBuilder: (
                      final BuildContext context,
                      final Widget child,
                      final ImageChunkEvent? loadingProgress,
                    ) {
                      if (loadingProgress == null) {
                        return Stack(
                          children: <Widget>[
                            child,
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<dynamic>(
                                        builder: (final BuildContext context) =>
                                            FullScreenInteractiveImage(
                                          child: child,
                                        ),
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
                        height: remToPx(20),
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
