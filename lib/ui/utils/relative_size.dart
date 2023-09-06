import 'package:kazahana/core/exports.dart';

class RelativeSize extends InheritedWidget {
  const RelativeSize({
    required this.data,
    required super.child,
    super.key,
  });

  final RelativeSizeData data;

  @override
  bool updateShouldNotify(final RelativeSize oldWidget) =>
      oldWidget.data != data;

  double size(final double scale) => data.size(scale);

  static RelativeSize of(final BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RelativeSize>()!;
}

class RelativeSizeData {
  const RelativeSizeData._(this.screenSize);

  factory RelativeSizeData.fromContext(final BuildContext context) =>
      RelativeSizeData._(MediaQuery.of(context).size);

  factory RelativeSizeData.fromPlatformDispatcher() => RelativeSizeData._(
        WidgetsBinding.instance.platformDispatcher.views.first.physicalSize /
            WidgetsBinding
                .instance.platformDispatcher.views.first.devicePixelRatio,
      );

  final Size screenSize;

  double size(final double scale) => scale * value;

  double get multiplier => SettingsDatabase.ready
      ? SettingsDatabase.settings.scaleMultiplier
      : defaultMultiplier;

  double get value => defaultRatio * screenSize.longestSide * multiplier;

  static const double defaultRatio = 0.025;
  static const double defaultMultiplier = 1;
}

extension RelativeSizeUtils on BuildContext {
  RelativeSize get r => RelativeSize.of(this);
}
