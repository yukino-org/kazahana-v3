import 'package:kazahana/core/exports.dart';

class RelativeScaler extends InheritedWidget {
  const RelativeScaler({
    required this.data,
    required super.child,
    super.key,
  });

  factory RelativeScaler.of(final BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RelativeScaler>()!;

  final RelativeScaleData data;

  @override
  bool updateShouldNotify(final RelativeScaler oldWidget) =>
      oldWidget.data != data;

  double scale(final double scale) => data.scale(scale);

  static const double defaultMultiplier = 1;
}

class RelativeScaleData {
  const RelativeScaleData(this.multiplier);

  factory RelativeScaleData.fromSettings() => SettingsDatabase.ready
      ? RelativeScaleData(SettingsDatabase.settings.scaleMultiplier)
      : defaultScale;

  final double multiplier;

  double scale(final double value) => ratio * value;

  static const double ratio = 14;
  static const double defaultMultiplier = 1;

  static const RelativeScaleData defaultScale =
      RelativeScaleData(defaultMultiplier);
}

extension RelativeScalerUtils on BuildContext {
  RelativeScaler get r => RelativeScaler.of(this);
}
