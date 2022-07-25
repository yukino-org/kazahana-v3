import '../../core/exports.dart';

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

  double size(final double scale) => scale * data.value;

  static RelativeSize of(final BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RelativeSize>()!;
}

class RelativeSizeData {
  RelativeSizeData._(this.value);

  factory RelativeSizeData.fromContext(final BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double value = 0.025 * size.longestSide;
    debugPrint('Relative size computed to $value');
    return RelativeSizeData._(value);
  }

  final double value;
}

extension RelativeSizeUtils on BuildContext {
  RelativeSize get r => RelativeSize.of(this);
}
