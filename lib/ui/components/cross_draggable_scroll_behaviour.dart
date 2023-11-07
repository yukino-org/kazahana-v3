import 'dart:ui';
import 'package:kazahana/core/exports.dart';

class DraggableScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class DraggableScrollConfiguration extends StatelessWidget {
  const DraggableScrollConfiguration({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(final BuildContext context) => ScrollConfiguration(
        behavior: DraggableScrollBehavior(),
        child: child,
      );
}
