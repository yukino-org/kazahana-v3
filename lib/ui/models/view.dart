import 'package:flutter/material.dart';
import './controller.dart';

typedef ViewBuilder<T extends Controller<T>> = Widget Function(BuildContext, T);

class View<T extends Controller<T>> extends StatefulWidget {
  const View({
    required final this.controller,
    required final this.builder,
    final Key? key,
  }) : super(key: key);

  final T controller;
  final ViewBuilder<T> builder;

  @override
  _ViewState<T> createState() => _ViewState<T>();
}

class _ViewState<T extends Controller<T>> extends State<View<T>> {
  late T controller;

  late final ControllerObserver<T> observer = ControllerObserver<T>(
    onReassemble: (final Controller<T> controller) async {
      if (!mounted) return;
      setState(() {});
    },
  );

  @override
  void initState() {
    super.initState();

    controller = widget.controller..subscribe(observer);
  }

  @override
  void didUpdateWidget(final View<T> oldWidget) {
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.unsubscribe(observer);
      controller = widget.controller..subscribe(observer);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.controller.unsubscribe(observer);

    super.dispose();
  }

  @override
  Widget build(final BuildContext context) =>
      widget.builder(context, widget.controller);
}
