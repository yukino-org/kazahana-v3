import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart' as media_kit;
import 'package:media_kit_video/media_kit_video.dart' as media_kit;

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

String sourceurl =
    ''; // TODO: Placeholder variable. Swap this out for the new video url provider.
String fileContents =
    ''; // TODO: Placeholder variable. Subtitles will have to be implemented later.

class _PlayerPageState extends State<PlayerPage> {
  late media_kit.Player _player;
  late media_kit.VideoController _controller;

  // final ValueNotifier<bool> _subtitlesEnabled = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _player = media_kit.Player();
    _controller = media_kit.VideoController(_player);
    _setDataSource();
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }

  Future<void> _setDataSource() async {
    await _player.open(media_kit.Media(sourceurl));
    // _controller.onClosedCaptionEnabled(true);
  }

  // Future<ClosedCaptionFile> _loadCaptions() async =>
  //     SubRipCaptionFile(fileContents);

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: media_kit.Video(
              controller: _controller,
              // bottomRight: (
              //   final BuildContext ctx,
              //   final MeeduPlayerController controller,
              //   final Responsive responsive,
              // ) {
              //   final double fontSize = responsive.ip(3);

              //   return CupertinoButton(
              //     padding: const EdgeInsets.all(5),
              //     minSize: 25,
              //     child: ValueListenableBuilder<bool>(
              //       valueListenable: _subtitlesEnabled,
              //       builder: (
              //         final BuildContext context,
              //         final bool enabled,
              //         final _,
              //       ) =>
              //           Text(
              //         'CC',
              //         style: TextStyle(
              //           fontSize: fontSize > 18 ? 18 : fontSize,
              //           color: Colors.white.withOpacity(
              //             enabled ? 1 : 0.4,
              //           ),
              //         ),
              //       ),
              //     ),
              //     onPressed: () {
              //       _subtitlesEnabled.value = !_subtitlesEnabled.value;
              //       _controller.onClosedCaptionEnabled(_subtitlesEnabled.value);
              //     },
              //   );
              // },
            ),
          ),
        ),
      );
}
