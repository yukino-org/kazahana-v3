import 'package:flutter/material.dart';
import '../../modules/state/hooks.dart';
import '../../modules/state/stateful_holder.dart';
import 'reactive_state_builder.dart';

class FallbackableNetworkImageProps {
  const FallbackableNetworkImageProps(
    this.url, [
    this.headers = const <String, String>{},
  ]);

  final String url;
  final Map<String, String> headers;
}

class FallbackableNetworkImage extends StatefulWidget {
  const FallbackableNetworkImage({
    required final this.image,
    required final this.fallback,
    final this.errorFallback,
    final Key? key,
  }) : super(key: key);

  final FallbackableNetworkImageProps image;
  final Widget fallback;
  final Widget? errorFallback;

  @override
  _FallbackableNetworkImageState createState() =>
      _FallbackableNetworkImageState();
}

class _FallbackableNetworkImageState extends State<FallbackableNetworkImage>
    with HooksMixin {
  late final NetworkImage networkImage;
  final StatefulValueHolder<ImageInfo?> networkImageInfo =
      StatefulValueHolder<ImageInfo?>(null);

  @override
  void initState() {
    super.initState();

    networkImage = NetworkImage(
      widget.image.url,
      headers: widget.image.headers,
    )..resolve(ImageConfiguration.empty).addListener(
        ImageStreamListener(
          (final ImageInfo image, final bool synchronousCall) {
            if (!mounted) return;
            setState(() {
              networkImageInfo.resolve(image);
            });
          },
          onError: (final Object exception, final StackTrace? stackTrace) {
            if (!mounted) return;
            setState(() {
              networkImageInfo.fail(null);
            });
          },
        ),
      );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    hookState.markReady();
  }

  @override
  void dispose() {
    networkImageInfo.value?.dispose();

    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => ReactiveStateBuilder(
        state: networkImageInfo.state,
        onResolving: (final BuildContext context) => widget.fallback,
        onResolved: (final BuildContext context) => Image(image: networkImage),
        onFailed: (final BuildContext context) =>
            widget.errorFallback ?? widget.fallback,
      );
}
