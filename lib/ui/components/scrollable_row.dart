import '../../core/exports.dart';
import 'body_padding.dart';

class ScrollableRow extends StatelessWidget {
  const ScrollableRow(
    this.children, {
    final Key? key,
  }) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            spacer,
            ...ListUtils.insertBetween(children, spacer),
            spacer,
          ],
        ),
      );

  SizedBox get spacer => SizedBox(width: HorizontalBodyPadding.size);
}
