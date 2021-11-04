import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import './update_tracker.dart';
import '../../../modules/app/state.dart';
import '../../../modules/database/database.dart';
import '../../../modules/helpers/screen.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/state/hooks.dart';
import '../../../modules/state/stateful_holder.dart';
import '../../../modules/state/states.dart';
import '../../../modules/translator/translator.dart';
import '../../components/full_screen_image.dart';
import '../settings_page/setting_labels/manga.dart';

class ListReader extends StatefulWidget {
  const ListReader({
    required final this.extractor,
    required final this.info,
    required final this.chapter,
    required final this.pages,
    required final this.onPop,
    required final this.previousChapter,
    required final this.nextChapter,
    final Key? key,
  }) : super(key: key);

  final MangaExtractor extractor;
  final MangaInfo info;
  final ChapterInfo chapter;
  final List<PageInfo> pages;

  final void Function() onPop;
  final void Function() previousChapter;
  final void Function() nextChapter;

  @override
  _ListReaderState createState() => _ListReaderState();
}

class _ListReaderState extends State<ListReader>
    with FullscreenMixin, HooksMixin {
  final Widget loader = const CircularProgressIndicator();

  late final Map<PageInfo, StatefulValueHolder<ImageDescriber?>> images =
      <PageInfo, StatefulValueHolder<ImageDescriber?>>{};

  bool hasSynced = false;
  bool ignoreScreenChanges = false;

  @override
  void initState() {
    super.initState();

    initFullscreen();

    onReady(() async {
      if (mounted && AppState.settings.value.mangaAutoFullscreen) {
        enterFullscreen();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    hookState.markReady();
  }

  @override
  void dispose() {
    if (!ignoreScreenChanges) {
      exitFullscreen();
    }

    super.dispose();
  }

  Future<void> getPage(final PageInfo page) async {
    images[page]!.state = ReactiveStates.resolving;

    final ImageDescriber image = await widget.extractor.getPage(page);

    if (mounted) {
      setState(() {
        images[page]!.value = image;
        images[page]!.state = ReactiveStates.resolved;
      });
    }
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
                  children: getSettingsManga(context, AppState.settings.value,
                      () async {
                    await SettingsBox.save(AppState.settings.value);

                    if (AppState.settings.value.mangaReaderMode !=
                        MangaMode.list) {
                      AppState.settings.value = AppState.settings.value;
                    }

                    if (mounted) {
                      setState(() {});
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _maybeUpdateTrackers(final int index) async {
    if (!hasSynced && index == widget.pages.length - 1) {
      hasSynced = true;

      await updateTrackers(
        widget.info.title,
        widget.extractor.id,
        widget.chapter.chapter,
        widget.chapter.volume,
      );
    }
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: Translator.t.back(),
            onPressed: widget.onPop,
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                ignoreScreenChanges = true;
                widget.previousChapter();
              },
              icon: const Icon(Icons.first_page),
            ),
            IconButton(
              onPressed: () {
                ignoreScreenChanges = true;
                widget.nextChapter();
              },
              icon: const Icon(Icons.last_page),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isFullscreened,
              builder: (
                final BuildContext builder,
                final bool isFullscreened,
                final Widget? child,
              ) =>
                  IconButton(
                onPressed: () async {
                  AppState.settings.value.mangaAutoFullscreen = !isFullscreened;

                  if (isFullscreened) {
                    exitFullscreen();
                  } else {
                    enterFullscreen();
                  }

                  await SettingsBox.save(AppState.settings.value);
                },
                icon: Icon(
                  isFullscreened ? Icons.fullscreen_exit : Icons.fullscreen,
                ),
              ),
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
        ),
        body: widget.pages.isEmpty
            ? Center(
                child: Text(Translator.t.noPagesFound()),
              )
            : ListView.builder(
                itemCount: widget.pages.length,
                itemBuilder: (final BuildContext context, final int index) {
                  final PageInfo page = widget.pages[index];

                  if (images[page] == null) {
                    images[page] = StatefulValueHolder<ImageDescriber?>(null);
                  }

                  if (!images[page]!.state.hasResolved) {
                    if (!images[page]!.state.isResolving) {
                      getPage(page);
                    }

                    return Padding(
                      padding: EdgeInsets.all(remToPx(5)),
                      child: Center(
                        child: loader,
                      ),
                    );
                  }

                  _maybeUpdateTrackers(index);

                  final ImageDescriber image = images[page]!.value!;
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
                            Align(
                              alignment: AlignmentDirectional.center,
                              child: child,
                            ),
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
