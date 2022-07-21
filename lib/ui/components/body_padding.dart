import '../../core/exports.dart';

class HorizontalBodyPadding extends StatelessWidget {
  const HorizontalBodyPadding(
    this.child, {
    final Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(final BuildContext context) =>
      Padding(padding: padding, child: child);

  static final double size = rem(0.75);
  static final EdgeInsets padding = EdgeInsets.symmetric(horizontal: size);
}
