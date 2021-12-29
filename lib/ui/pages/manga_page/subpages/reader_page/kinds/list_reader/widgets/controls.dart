import 'package:flutter/material.dart';
import '../../../../../../../../config/defaults.dart';
import '../../../../../../../../modules/app/state.dart';
import '../../../../../../../../modules/database/database.dart';
import '../../../../../../../../modules/helpers/ui.dart';
import '../../../controller.dart';

class ListReaderControls extends StatelessWidget {
  const ListReaderControls({
    required final this.controller,
    final Key? key,
  }) : super(key: key);

  final ReaderPageController controller;

  @override
  Widget build(final BuildContext context) {
    final double height =
        Theme.of(context).textTheme.subtitle2!.fontSize! + remToPx(1.4);

    final EdgeInsets topPadding = EdgeInsets.symmetric(
      horizontal: remToPx(0.5),
      vertical: remToPx(0.8),
    );

    final EdgeInsets inPadding = EdgeInsets.symmetric(
      horizontal: remToPx(0.3),
      vertical: remToPx(0.2),
    );

    final double boxSpacer = remToPx(0.2);
    const int boxContentLength = 3;
    const double boxSpacerLength = 1;

    final double preBoxWidth =
        (Theme.of(context).textTheme.headline4!.fontSize! * boxContentLength) +
            (boxSpacer * boxSpacerLength) +
            inPadding.left +
            inPadding.right;

    final ResponsiveSize responsiveSize = ResponsiveSize.fromSize(
      Size.fromWidth(
        MediaQuery.of(context).size.width -
            topPadding.left -
            topPadding.right -
            preBoxWidth,
      ),
    );

    final bool displaySlider = AppState.settings.value.manga.listModeSizing ==
        MangaListModeSizing.custom;

    final double sliderWidth = displaySlider
        ? responsiveSize.isLg
            ? MediaQuery.of(context).size.width / 3
            : responsiveSize.isXs
                ? MediaQuery.of(context).size.width / 2
                : responsiveSize.width
        : 0;

    final double boxWidth = preBoxWidth + sliderWidth;

    return Padding(
      padding: topPadding,
      child: SizedBox(
        height: height,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomRight,
              child: AnimatedContainer(
                duration: Defaults.animationsNormal,
                curve: Curves.easeInOut,
                width: boxWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(remToPx(0.25)),
                    ),
                    color: Theme.of(context).cardColor,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: inPadding,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Material(
                      type: MaterialType.transparency,
                      shape: const CircleBorder(),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          Theme.of(context).textTheme.headline4!.fontSize!,
                        ),
                        onTap: controller.previousChapterAvailable
                            ? () {
                                controller.ignoreScreenChanges = true;
                                controller.previousChapter();
                              }
                            : null,
                        child: Icon(
                          Icons.first_page,
                          color: controller.previousChapterAvailable
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          size: Theme.of(context).textTheme.headline4?.fontSize,
                        ),
                      ),
                    ),
                    SizedBox(width: boxSpacer),
                    Material(
                      type: MaterialType.transparency,
                      shape: const CircleBorder(),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          Theme.of(context).textTheme.headline4!.fontSize!,
                        ),
                        onTap: controller.nextChapterAvailable
                            ? () {
                                controller.ignoreScreenChanges = true;
                                controller.nextChapter();
                              }
                            : null,
                        child: Icon(
                          Icons.last_page,
                          color: controller.nextChapterAvailable
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          size: Theme.of(context).textTheme.headline4?.fontSize,
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: Defaults.animationsFast,
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      child: Builder(
                        key: ValueKey<bool>(displaySlider),
                        builder: (final BuildContext context) {
                          if (displaySlider) {
                            return SizedBox(
                              width: sliderWidth,
                              child: SliderTheme(
                                data: SliderThemeData(
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: remToPx(0.3),
                                  ),
                                  overlayShape: RoundSliderOverlayShape(
                                    overlayRadius: remToPx(0.9),
                                  ),
                                  trackHeight: remToPx(0.15),
                                  showValueIndicator: ShowValueIndicator.always,
                                ),
                                child: StatefulBuilder(
                                  builder: (
                                    final BuildContext context,
                                    final StateSetter setState,
                                  ) =>
                                      Slider(
                                    min: 1,
                                    max: 100,
                                    value: AppState.settings.value.manga
                                        .listModeCustomWidth
                                        .toDouble(),
                                    label:
                                        '${AppState.settings.value.manga.listModeCustomWidth}%',
                                    onChanged: (final double value) async {
                                      setState(() {
                                        AppState.settings.value.manga
                                                .listModeCustomWidth =
                                            value.toInt();
                                      });
                                      controller.reassemble();
                                    },
                                    onChangeEnd: (final double value) async {
                                      AppState.settings.value.manga
                                          .listModeCustomWidth = value.toInt();
                                      await SettingsBox.save(
                                        AppState.settings.value,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    Material(
                      type: MaterialType.transparency,
                      shape: const CircleBorder(),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          Theme.of(context).textTheme.headline4!.fontSize!,
                        ),
                        onTap: () async {
                          const List<MangaListModeSizing> mangaListModeSizings =
                              MangaListModeSizing.values;

                          final int currentIndex =
                              mangaListModeSizings.indexWhere(
                            (final MangaListModeSizing x) =>
                                x ==
                                AppState.settings.value.manga.listModeSizing,
                          );

                          AppState.settings.value.manga.listModeSizing =
                              currentIndex + 1 < mangaListModeSizings.length
                                  ? mangaListModeSizings[currentIndex + 1]
                                  : mangaListModeSizings.first;

                          await SettingsBox.save(AppState.settings.value);
                          controller.mangaController.reassemble();
                        },
                        child: SizedBox(
                          height:
                              Theme.of(context).textTheme.headline4?.fontSize,
                          width:
                              Theme.of(context).textTheme.headline4?.fontSize,
                          child: AnimatedSwitcher(
                            duration: Defaults.animationsFast,
                            switchInCurve: Curves.easeInOut,
                            switchOutCurve: Curves.easeInOut,
                            child: Icon(
                              sizingIcon,
                              key: ValueKey<IconData>(sizingIcon),
                              color: Colors.white,
                              size: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  ?.fontSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData get sizingIcon {
    switch (AppState.settings.value.manga.listModeSizing) {
      case MangaListModeSizing.custom:
        return Icons.photo_size_select_small;

      case MangaListModeSizing.fitHeight:
        return Icons.swap_vert;

      case MangaListModeSizing.fitWidth:
        return Icons.swap_horiz;
    }
  }
}
