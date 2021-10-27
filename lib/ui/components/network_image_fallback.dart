import 'package:flutter/material.dart';
import '../../modules/helpers/stateful_holder.dart';

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
    with DidLoadStater {
  LoadState state = LoadState.waiting;
  ImageInfo? imageInfo;
  late final NetworkImage networkImage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    doLoadStateIfHasnt();
  }

  @override
  void dispose() {
    imageInfo?.dispose();

    super.dispose();
  }

  @override
  Future<void> load() async {
    networkImage = NetworkImage(widget.url);
    networkImage.resolve(ImageConfiguration.empty).addListener(
          ImageStreamListener(
            (final ImageInfo image, final bool synchronousCall) {
              if (mounted) {
                setState(() {
                  imageInfo = image;
                  state = LoadState.resolved;
                });
              }
            },
            onError: (final Object exception, final StackTrace? stackTrace) {
              if (mounted) {
                setState(() {
                  state = LoadState.failed;
                });
              }
            },
          ),
        );
  }

  @override
  Widget build(final BuildContext context) {
    if (state == LoadState.resolved) {
      return Image(image: networkImage);
    }

    if (state == LoadState.failed && widget.errorPlaceholder != null) {
      return widget.errorPlaceholder!;
    }

    return widget.placeholder;
  }
}
