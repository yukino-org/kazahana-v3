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

  static const double paddingAny = 0.75;
  static const double paddingMd = 1;

  static double paddingValue(final BuildContext context) =>
      context.r.scale(paddingAny, md: paddingMd);

  static EdgeInsets padding(final BuildContext context) =>
      EdgeInsets.symmetric(horizontal: paddingValue(context));
}
