import 'package:flutter/material.dart';
import '../../modules/state/states.dart';

class ReactiveStateBuilder extends StatelessWidget {
  const ReactiveStateBuilder({
    required final this.state,
    required final this.onResolving,
    required final this.onResolved,
    required final this.onFailed,
    final this.onWaiting,
    final Key? key,
  }) : super(key: key);

  final ReactiveStates state;
  final WidgetBuilder? onWaiting;
  final WidgetBuilder onResolving;
  final WidgetBuilder onResolved;
  final WidgetBuilder onFailed;

  @override
  Widget build(final BuildContext context) {
    switch (state) {
      case ReactiveStates.waiting:
        return onWaiting != null ? onWaiting!(context) : onResolving(context);

      case ReactiveStates.resolving:
        return onResolving(context);

      case ReactiveStates.resolved:
        return onResolved(context);

      case ReactiveStates.failed:
        return onFailed(context);
    }
  }
}
