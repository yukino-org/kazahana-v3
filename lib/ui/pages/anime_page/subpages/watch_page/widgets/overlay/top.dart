import 'package:flutter/material.dart';
import './overlay.dart';
import '../../../../../../../modules/app/state.dart';
import '../../../../../../../modules/database/database.dart';
import '../../../../../../../modules/helpers/ui.dart';
import '../../../../../../../modules/translator/translator.dart';
import '../../../../../../../modules/video_player/video_player.dart';
import '../../../../../../../ui/components/material_tiles/radio.dart';
import '../../../../../../../ui/pages/settings_page/setting_labels/anime.dart';
import '../../controller.dart';

class OverlayTop extends StatelessWidget {
  const OverlayTop({
    required final this.controller,
    final Key? key,
  }) : super(key: key);

  final WatchPageController controller;

  Future<void> showOptions(final BuildContext context) async {
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
            child: SingleChildScrollView(
              child: Wrap(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      RadioMaterialTile<double>(
                        title: Text(Translator.t.speed()),
                        icon: const Icon(Icons.speed),
                        value: controller.speed,
                        labels: VideoPlayer.allowedSpeeds.asMap().map(
                              (final int k, final double v) =>
                                  MapEntry<double, String>(v, '${v}x'),
                            ),
                        onChanged: (final double val) async {
                          await controller.videoPlayer?.setSpeed(val);
                          setState(() {
                            controller.speed = val;
                          });
                        },
                      ),
                      ...getSettingsAnime(
                        context,
                        AppState.settings.value,
                        () async {
                          await SettingsBox.save(AppState.settings.value);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            top: remToPx(0.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                ),
                tooltip: Translator.t.back(),
                onPressed: controller.exit,
                padding: EdgeInsets.only(
                  right: remToPx(1),
                  top: remToPx(0.5),
                  bottom: remToPx(0.5),
                ),
                color: Colors.white,
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      controller.animeController.info.value!.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.headline6?.fontSize,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${Translator.t.episode()} ${controller.animeController.episode!.episode} ${Translator.t.of()} ${controller.animeController.info.value!.episodes.length}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              PlayerOverlay.buildLock(context, controller),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () async {
                  await showOptions(context);
                },
                color: Colors.white,
              ),
            ],
          ),
        ),
      );
}
