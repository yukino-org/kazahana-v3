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
      oldWidget.data != data && oldWidget.data != data;

  double scale(
    final double any, {
    final double? sm,
    final double? md,
    final double? lg,
    final double? xl,
  }) =>
      data.scale(any, sm: sm, md: md, lg: lg, xl: xl);

  T responsive<T>(
    final T any, {
    final T? sm,
    final T? md,
    final T? lg,
    final T? xl,
  }) =>
      data.responsive(any, sm: sm, md: md, lg: lg, xl: xl);

  T responsiveBuilder<T>(
    final T Function() any, {
    final T Function()? sm,
    final T Function()? md,
    final T Function()? lg,
    final T Function()? xl,
  }) =>
      data.responsiveBuilder(any, sm: sm, md: md, lg: lg, xl: xl);
}

class RelativeScaleData {
  const RelativeScaleData({
    required this.multiplier,
    required this.screen,
  });

  factory RelativeScaleData.fromSettingsNoResponsive() =>
      RelativeScaleData(multiplier: getScaleMultiplier(), screen: Size.zero);

  final double multiplier;
  final Size screen;

  double scale(
    final double any, {
    final double? sm,
    final double? md,
    final double? lg,
    final double? xl,
  }) =>
      scaleRatio * responsive(any, sm: sm, md: md, lg: lg, xl: xl);

  T responsive<T>(
    final T any, {
    final T? sm,
    final T? md,
    final T? lg,
    final T? xl,
  }) =>
      switch (screen.width) {
        > xlWidth when xl != null => xl,
        > lgWidth when lg != null => lg,
        > mdWidth when md != null => md,
        > smWidth when sm != null => sm,
        _ => any,
      };

  T responsiveBuilder<T>(
    final T Function() any, {
    final T Function()? sm,
    final T Function()? md,
    final T Function()? lg,
    final T Function()? xl,
  }) =>
      switch (screen.width) {
        > xlWidth when xl != null => xl(),
        > lgWidth when lg != null => lg(),
        > mdWidth when md != null => md(),
        > smWidth when sm != null => sm(),
        _ => any(),
      };

  RelativeScaleData copyWith({
    final double? multiplier,
    final Size? screen,
  }) =>
      RelativeScaleData(
        multiplier: multiplier ?? this.multiplier,
        screen: screen ?? this.screen,
      );

  static const double scaleRatio = 14;
  static const double defaultScaleMultiplier = 1;

  static const double smWidth = 640;
  static const double mdWidth = 768;
  static const double lgWidth = 1024;
  static const double xlWidth = 1280;

  static double getScaleMultiplier() => SettingsDatabase.ready
      ? SettingsDatabase.settings.scaleMultiplier
      : defaultScaleMultiplier;

  static Size getScreenSize(final BuildContext context) =>
      MediaQuery.of(context).size;
}

extension RelativeScalerUtils on BuildContext {
  RelativeScaler get r => RelativeScaler.of(this);
}
