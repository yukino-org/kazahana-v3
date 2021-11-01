import 'package:flutter/material.dart';
import '../../modules/state/hooks.dart';
import '../../modules/state/states.dart';

class FallbackableNetworkImage extends StatefulWidget {
  const FallbackableNetworkImage({
    required final this.url,
    required final this.placeholder,
    final this.headers = const <String, String>{},
    final this.errorPlaceholder,
    final Key? key,
  }) : super(key: key);

  final String url;
  final Map<String, String> headers;
  final Widget placeholder;
  final Widget? errorPlaceholder;

  @override
  _FallbackableNetworkImageState createState() =>
      _FallbackableNetworkImageState();
}

class _FallbackableNetworkImageState extends State<FallbackableNetworkImage>
    with HooksMixin {
  ReactiveStates state = ReactiveStates.waiting;
  ImageInfo? imageInfo;
  late final NetworkImage networkImage;

  @override
  void initState() {
    super.initState();

    onReady(() async {
      networkImage = NetworkImage(widget.url);
      networkImage.resolve(ImageConfiguration.empty).addListener(
            ImageStreamListener(
              (final ImageInfo image, final bool synchronousCall) {
                if (mounted) {
                  setState(() {
                    imageInfo = image;
                    state = ReactiveStates.resolved;
                  });
                }
              },
              onError: (final Object exception, final StackTrace? stackTrace) {
                if (mounted) {
                  setState(() {
                    state = ReactiveStates.failed;
                  });
                }
              },
            ),
          );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    hookState.markReady();
  }

  @override
  void dispose() {
    imageInfo?.dispose();

    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    if (state == ReactiveStates.resolved) {
      return Image(image: networkImage);
    }

    if (state == ReactiveStates.failed && widget.errorPlaceholder != null) {
      return widget.errorPlaceholder!;
    }

    return widget.placeholder;
  }
}
