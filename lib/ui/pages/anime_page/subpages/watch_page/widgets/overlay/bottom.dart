import 'package:flutter/material.dart';
import 'package:utilx/utilities/utils.dart';
import '../../../../../../../modules/app/state.dart';
import '../../../../../../../modules/helpers/ui.dart';
import '../../../../../../../modules/state/simple_mutable.dart';
import '../../../../../../../modules/translator/translator.dart';
import '../../controller.dart';
import '../actions_button.dart';

class OverlayBottom extends StatelessWidget {
  OverlayBottom({
    required final this.controller,
    final Key? key,
  }) : super(key: key);

  final WatchPageController controller;
  final SimpleMutable<bool> wasPausedBySlider = SimpleMutable<bool>(false);

  Widget buildLayoutedButton(
    final BuildContext context,
    final List<Widget> children,
    final int maxPerWhenSm,
  ) {
    final double width = MediaQuery.of(context).size.width;
    final Widget spacer = SizedBox(
      width: remToPx(0.4),
    );

    if (width < ResponsiveSizes.sm) {
      final List<List<Widget>> rows = ListUtils.chunk(children, maxPerWhenSm);

      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: rows
            .map(
              (final List<Widget> x) => Flexible(
                child: Row(
                  children: ListUtils.insertBetween(x, spacer),
                ),
              ),
            )
            .toList(),
      );
    }

    return Row(
      children: ListUtils.insertBetween(children, spacer),
    );
  }

  @override
  Widget build(final BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            child: buildLayoutedButton(
              context,
              <Widget>[
                Expanded(
                  child: ActionButton(
                    icon: Icons.skip_previous,
                    label: Translator.t.previous(),
                    onPressed: () {
                      controller.ignoreScreenChanges = true;
                      controller.previousEpisode();
                    },
                    enabled: controller.previousEpisodeAvailable,
                  ),
                ),
                Expanded(
                  child: ActionButton(
                    icon: Icons.fast_forward,
                    label: Translator.t.skipIntro(),
                    onPressed: () async {
                      await controller.seek(SeekType.intro);
                    },
                    enabled: controller.isReady,
                  ),
                ),
                Expanded(
                  child: ActionButton(
                    icon: Icons.playlist_play,
                    label: Translator.t.sources(),
                    onPressed: () async {
                      await controller.showSelectSources(context);
                    },
                    enabled: controller.sources?.isNotEmpty ?? false,
                  ),
                ),
                Expanded(
                  child: ActionButton(
                    icon: Icons.skip_next,
                    label: Translator.t.next(),
                    onPressed: () {
                      controller.ignoreScreenChanges = true;
                      controller.nextEpisode();
                    },
                    enabled: controller.nextEpisodeAvailable,
                  ),
                ),
              ],
              2,
            ),
          ),
          ValueListenableBuilder<VideoDuration>(
            valueListenable: controller.duration,
            builder: (
              final BuildContext context,
              final VideoDuration duration,
              final Widget? child,
            ) =>
                Row(
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(
                    minWidth: remToPx(1.8),
                  ),
                  child: Text(
                    DurationUtils.pretty(
                      duration.current,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: remToPx(0.3),
                      ),
                      showValueIndicator: ShowValueIndicator.always,
                      thumbColor: !controller.isReady
                          ? Colors.white.withOpacity(
                              0.5,
                            )
                          : null,
                    ),
                    child: Slider(
                      label: DurationUtils.pretty(
                        duration.current,
                      ),
                      value: duration.current.inSeconds.toDouble(),
                      max: duration.total.inSeconds.toDouble(),
                      onChanged: controller.isReady
                          ? (
                              final double value,
                            ) {
                              controller.duration.value = VideoDuration(
                                Duration(seconds: value.toInt()),
                                duration.total,
                              );
                            }
                          : null,
                      onChangeStart: controller.isReady
                          ? (
                              final double value,
                            ) async {
                              if (controller.isPlaying) {
                                await controller.videoPlayer!.pause();

                                wasPausedBySlider.value = true;
                              }
                            }
                          : null,
                      onChangeEnd: controller.isReady
                          ? (
                              final double value,
                            ) async {
                              await controller.videoPlayer!.seek(
                                Duration(seconds: value.toInt()),
                              );

                              if (wasPausedBySlider.value) {
                                await controller.videoPlayer!.play();
                                wasPausedBySlider.value = false;
                              }
                            }
                          : null,
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: remToPx(1.8),
                  ),
                  child: Text(
                    DurationUtils.pretty(
                      duration.total,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: remToPx(0.5),
                ),
                if (AppState.isMobile) ...<Widget>[
                  Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        remToPx(0.2),
                      ),
                      onTap: () async {
                        await controller.setLandscape(
                          enabled: AppState.settings.value.animeForceLandscape,
                        );
                      },
                      child: Icon(
                        Icons.screen_rotation,
                        size: Theme.of(context).textTheme.headline6?.fontSize,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: remToPx(0.7),
                  ),
                ],
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(remToPx(0.2)),
                    onTap: () async {
                      await controller.setFullscreen(
                        enabled: !AppState.settings.value.animeAutoFullscreen,
                      );
                    },
                    child: Icon(
                      AppState.settings.value.animeAutoFullscreen
                          ? Icons.fullscreen_exit
                          : Icons.fullscreen,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      );
}
