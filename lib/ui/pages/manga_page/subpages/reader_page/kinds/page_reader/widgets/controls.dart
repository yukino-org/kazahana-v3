import 'package:flutter/material.dart';
import '../../../../../../../../modules/helpers/ui.dart';
import '../controller.dart';

class PageReaderControls extends StatelessWidget {
  const PageReaderControls({
    required final this.controller,
    final Key? key,
  }) : super(key: key);

  final PageReaderController controller;

  @override
  Widget build(final BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: remToPx(0.5),
          vertical:
              remToPx(1) + Theme.of(context).textTheme.subtitle2!.fontSize!,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(remToPx(0.25)),
            ),
            color: Theme.of(context).cardColor,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: remToPx(0.5),
            ),
            child: Row(
              children: <Widget>[
                Material(
                  type: MaterialType.transparency,
                  shape: const CircleBorder(),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      Theme.of(context).textTheme.headline4!.fontSize!,
                    ),
                    onTap: controller.readerController.previousChapterAvailable
                        ? () {
                            controller.readerController.ignoreScreenChanges =
                                true;
                            controller.readerController.previousChapter();
                          }
                        : null,
                    child: Icon(
                      Icons.first_page,
                      color:
                          controller.readerController.previousChapterAvailable
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                      size: Theme.of(context).textTheme.headline4?.fontSize,
                    ),
                  ),
                ),
                Expanded(
                  child: Wrap(
                    children: <Widget>[
                      SliderTheme(
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
                        child: RotatedBox(
                          quarterTurns: controller.isReversed ? 2 : 0,
                          child: Slider(
                            value:
                                controller.readerController.currentPageIndex +
                                    1,
                            min: 1,
                            max: controller.readerController.pages.value!.length
                                .toDouble(),
                            label:
                                (controller.readerController.currentPageIndex +
                                        1)
                                    .toString(),
                            onChanged: (final double value) async {
                              await controller.animateToPage(value.toInt() - 1);
                            },
                            onChangeEnd: (final double value) async {
                              await controller
                                  .setCurrentPageIndex(value.toInt() - 1);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  type: MaterialType.transparency,
                  shape: const CircleBorder(),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      Theme.of(context).textTheme.headline4!.fontSize!,
                    ),
                    onTap: controller.readerController.nextChapterAvailable
                        ? () {
                            controller.readerController.ignoreScreenChanges =
                                true;
                            controller.readerController.nextChapter();
                          }
                        : null,
                    child: Icon(
                      Icons.last_page,
                      color: controller.readerController.nextChapterAvailable
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      size: Theme.of(context).textTheme.headline4?.fontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
