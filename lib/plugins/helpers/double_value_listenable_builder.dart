import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef DoubleValueWidgetBuilder<T, T2> = Widget Function(
  BuildContext context,
  T value1,
  T2 value2,
  Widget? child,
);

class DoubleValueListenableBuilder<T, T2> extends StatefulWidget {
  const DoubleValueListenableBuilder({
    required final this.valueListenable1,
    required final this.valueListenable2,
    required final this.builder,
    final this.child,
    final Key? key,
  }) : super(key: key);

  final ValueListenable<T> valueListenable1;
  final ValueListenable<T2> valueListenable2;
  final DoubleValueWidgetBuilder<T, T2> builder;
  final Widget? child;

  @override
  State<StatefulWidget> createState() =>
      _DoubleValueListenableBuilderState<T, T2>();
}

class _DoubleValueListenableBuilderState<T, T2>
    extends State<DoubleValueListenableBuilder<T, T2>> {
  late T value1;
  late T2 value2;

  @override
  void initState() {
    super.initState();
    value1 = widget.valueListenable1.value;
    value2 = widget.valueListenable2.value;
    widget.valueListenable1.addListener(_valueChanged1);
    widget.valueListenable2.addListener(_valueChanged2);
  }

  @override
  void didUpdateWidget(final DoubleValueListenableBuilder<T, T2> oldWidget) {
    if (oldWidget.valueListenable1 != widget.valueListenable1 &&
        oldWidget.valueListenable2 != widget.valueListenable2) {
      oldWidget.valueListenable1.removeListener(_valueChanged1);
      value1 = widget.valueListenable1.value;
      widget.valueListenable1.addListener(_valueChanged1);

      oldWidget.valueListenable2.removeListener(_valueChanged2);
      value2 = widget.valueListenable2.value;
      widget.valueListenable2.addListener(_valueChanged2);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.valueListenable1.removeListener(_valueChanged1);
    widget.valueListenable2.removeListener(_valueChanged2);
    super.dispose();
  }

  void _valueChanged1() {
    setState(() {
      value1 = widget.valueListenable1.value;
    });
  }

  void _valueChanged2() {
    setState(() {
      value2 = widget.valueListenable2.value;
    });
  }

  @override
  Widget build(final BuildContext context) =>
      widget.builder(context, value1, value2, widget.child);
}
