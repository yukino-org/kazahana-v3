import 'package:flutter/material.dart';
import './controller.dart';

typedef ViewBuilder<T extends Controller> = Widget Function(BuildContext, T);

class View<T extends Controller> extends StatefulWidget {
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

class _ViewState<T extends Controller> extends State<View<T>> {
  @override
  void initState() {
    super.initState();

    widget.controller
      ..setup()
      ..addListener(_controllerListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    widget.controller.ready(context);
  }

  @override
  void dispose() {
    widget.controller
      ..removeListener(_controllerListener)
      ..dispose();

    super.dispose();
  }

  void _controllerListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(final BuildContext context) =>
      widget.builder(context, widget.controller);
}
