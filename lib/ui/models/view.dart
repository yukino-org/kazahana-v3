import 'package:flutter/material.dart';
import './controller.dart';

typedef ViewBuilder<T extends Controller> = Widget Function(BuildContext, T);

typedef ViewListener<T extends Controller> = void Function(T, bool);

class View<T extends Controller> extends StatefulWidget {
  const View({
    required final this.controller,
    required final this.builder,
    final this.afterSetup,
    final this.afterReady,
    final this.afterDispose,
    final Key? key,
  }) : super(key: key);

  final T controller;
  final ViewListener<T>? afterSetup;
  final ViewListener<T>? afterReady;
  final ViewListener<T>? afterDispose;
  final ViewBuilder<T> builder;

  @override
  _ViewState<T> createState() => _ViewState<T>();
}

class _ViewState<T extends Controller> extends State<View<T>> {
  @override
  void initState() {
    super.initState();

    widget.controller
      ..subscribe(_controllerListener)
      ..setup().then((final bool done) {
        if (mounted) {
          widget.afterSetup?.call(widget.controller, done);
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    widget.controller.ready().then((final bool done) {
      if (mounted) {
        widget.afterReady?.call(widget.controller, done);
      }
    });
  }

  @override
  void dispose() {
    widget.controller
      ..unsubscribe(_controllerListener)
      ..dispose().then((final bool disposed) {
        if (mounted) {
          widget.afterDispose?.call(widget.controller, disposed);
        }
      });

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
