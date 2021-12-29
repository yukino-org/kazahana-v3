import 'package:flutter/material.dart';
import '../../../../../../../config/defaults.dart';
import '../../../../../../../modules/helpers/ui.dart';
import '../../../../../../../modules/translator/translator.dart';
import '../../controller.dart';

class OverlayMiddle extends StatefulWidget {
  const OverlayMiddle({
    required final this.controller,
    final Key? key,
  }) : super(key: key);

  final WatchPageController controller;

  @override
  _OverlayMiddleState createState() => _OverlayMiddleState();
}

class _OverlayMiddleState extends State<OverlayMiddle>
    with SingleTickerProviderStateMixin {
  late final AnimationController playPauseController = AnimationController(
    vsync: this,
    duration: Defaults.animationsSlower,
    value: widget.controller.isPlaying ? 1 : 0,
  );

  @override
  void dispose() {
    playPauseController.dispose();

    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    widget.controller.isPlaying
        ? playPauseController.forward()
        : playPauseController.reverse();

    if (widget.controller.sources?.isEmpty ?? false) {
      return Text(
        Translator.t.noValidSources(),
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.subtitle1?.fontSize,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      );
    }

    if (widget.controller.message != null) {
      return widget.controller.message!;
    }

    if (widget.controller.isReady && !widget.controller.isBuffering) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Material(
            type: MaterialType.transparency,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: IconButton(
              iconSize: remToPx(2),
              onPressed: () async {
                await widget.controller.seek(SeekType.backward);
              },
              icon: const Icon(
                Icons.fast_rewind,
              ),
              color: Colors.white,
            ),
          ),
          Material(
            type: MaterialType.transparency,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: IconButton(
              iconSize: remToPx(3),
              onPressed: () {
                widget.controller.isPlaying
                    ? widget.controller.videoPlayer!.pause()
                    : widget.controller.videoPlayer!.play();
              },
              icon: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: playPauseController,
              ),
              color: Colors.white,
            ),
          ),
          Material(
            type: MaterialType.transparency,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: IconButton(
              iconSize: remToPx(2),
              onPressed: () async {
                await widget.controller.seek(SeekType.forward);
              },
              icon: const Icon(
                Icons.fast_forward,
              ),
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    return const CircularProgressIndicator();
  }
}
