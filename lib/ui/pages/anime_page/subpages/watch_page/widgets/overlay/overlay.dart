import 'package:flutter/material.dart';
import './bottom.dart';
import './middle.dart';
import './top.dart';
import '../../../../../../../config/defaults.dart';
import '../../../../../../../modules/helpers/ui.dart';
import '../../controller.dart';

class PlayerOverlay extends StatelessWidget {
  const PlayerOverlay({
    required final this.controller,
    final Key? key,
  }) : super(key: key);

  final WatchPageController controller;

  Widget buildOverlay({
    required final BuildContext context,
    required final Widget firstChild,
    final Widget secondChild = const SizedBox.shrink(),
    final bool? enabled,
  }) =>
      AnimatedSwitcher(
        duration: Defaults.animationsNormal,
        child: enabled ?? showControls ? firstChild : secondChild,
      );

  @override
  Widget build(final BuildContext context) {
    if (controller.locked) {
      return Stack(
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: Material(
              type: MaterialType.transparency,
              borderRadius: BorderRadius.circular(remToPx(0.2)),
              child: IconButton(
                onPressed: () {
                  controller.locked = !controller.locked;
                  controller.rebuild();
                },
                icon: const Icon(Icons.lock),
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: remToPx(0.7),
        ),
        child: Column(
          children: <Widget>[
            buildOverlay(
              context: context,
              firstChild: OverlayTop(controller: controller),
            ),
            buildOverlay(
              context: context,
              firstChild: OverlayMiddle(controller: controller),
              enabled: showControls || controller.currentPlayerWidget == null,
            ),
            buildOverlay(
              context: context,
              firstChild: OverlayBottom(controller: controller),
            ),
          ],
        ),
      ),
    );
  }

  bool get showControls => controller.isReady || controller.showControls;

  static Widget buildLock(
    final BuildContext context,
    final WatchPageController controller,
  ) =>
      Align(
        alignment: AlignmentDirectional.topEnd,
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(remToPx(0.2)),
          child: IconButton(
            onPressed: () {
              controller.locked = !controller.locked;
              controller.rebuild();
            },
            icon: Icon(controller.locked ? Icons.lock : Icons.lock_open),
            color: Colors.white,
          ),
        ),
      );
}
