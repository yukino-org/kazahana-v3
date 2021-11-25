import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import './controller.dart';
import './widgets/overlay/overlay.dart';
import '../../../../../config/defaults.dart';
import '../../../../../modules/helpers/logger.dart';
import '../../../../models/view.dart';
import '../../controller.dart';

final Logger logger = Logger.of('watch_page');

class WatchPage extends StatefulWidget {
  const WatchPage({
    required final this.animeController,
    final Key? key,
  }) : super(key: key);

  final AnimePageController animeController;

  @override
  _WatchPageState createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage>
    with SingleTickerProviderStateMixin {
  late final WatchPageController controller =
      WatchPageController(animeController: widget.animeController);

  final FocusNode keyBoardFocusNode = FocusNode();

  Timer? mouseOverlayTimer;

  @override
  void dispose() {
    keyBoardFocusNode.dispose();
    mouseOverlayTimer?.cancel();
    controller.dispose();

    super.dispose();
  }

  /// [kind] can be 1 (move) or 2 (tap)
  void _updateOverlayMovement(final int kind) {
    switch (kind) {
      case 1:
        if (controller.isPlaying) {
          if (!controller.showControls) {
            controller.showControls = true;
            controller.rebuild();
          }

          mouseOverlayTimer?.cancel();
          mouseOverlayTimer = Timer(Defaults.mouseOverlayDuration, () {
            controller.showControls = false;
            controller.rebuild();
          });
        }
        break;

      case 2:
        mouseOverlayTimer?.cancel();
        controller.showControls = !controller.showControls;
        controller.rebuild();
        break;

      default:
    }
  }

  @override
  Widget build(final BuildContext context) => View<WatchPageController>(
        controller: controller,
        afterReady: (
          final WatchPageController controller,
          final bool done,
        ) async {
          await controller.showSelectSources(context);
          if (mounted && controller.currentSourceIndex == null) {
            Navigator.of(context).pop();
          }
        },
        builder: (
          final BuildContext context,
          final WatchPageController controller,
        ) =>
            RawKeyboardListener(
          focusNode: keyBoardFocusNode,
          autofocus: true,
          onKey: (final RawKeyEvent event) =>
              controller.getKeyboard(context).onRawKeyEvent(event),
          child: Material(
            type: MaterialType.transparency,
            child: MouseRegion(
              onEnter: (final PointerEnterEvent event) {
                _updateOverlayMovement(1);
              },
              onHover: (final PointerHoverEvent event) {
                if (event.kind == PointerDeviceKind.mouse &&
                    event.delta.distance > 1) {
                  _updateOverlayMovement(1);
                }
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _updateOverlayMovement(2);
                },
                child: Stack(
                  children: <Widget>[
                    if (controller.currentPlayerWidget != null)
                      controller.currentPlayerWidget!,
                    PlayerOverlay(controller: controller),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
