import 'package:kazahana/core/exports.dart';

class StatedBuilder extends StatelessWidget {
  const StatedBuilder(
    this.state, {
    required this.waiting,
    required this.processing,
    required this.finished,
    required this.failed,
    super.key,
  });

  final States state;
  final WidgetBuilder waiting;
  final WidgetBuilder processing;
  final WidgetBuilder finished;
  final WidgetBuilder failed;

  @override
  Widget build(final BuildContext context) {
    if (state == States.waiting) return waiting(context);
    if (state == States.processing) return processing(context);
    if (state == States.finished) return finished(context);
    return failed(context);
  }
}
