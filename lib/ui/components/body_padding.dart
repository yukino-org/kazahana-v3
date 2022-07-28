import 'package:kazahana/core/exports.dart';
import '../exports.dart';

class HorizontalBodyPadding extends StatelessWidget {
  const HorizontalBodyPadding(
    this.child, {
    super.key,
  });

  final Widget child;

  @override
  Widget build(final BuildContext context) =>
      Padding(padding: padding(context), child: child);

  static const double sizeScale = 0.75;
  static double size(final BuildContext context) => context.r.size(sizeScale);
  static EdgeInsets padding(final BuildContext context) =>
      EdgeInsets.symmetric(horizontal: size(context));
}
