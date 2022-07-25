import '../../core/exports.dart';
import 'body_padding.dart';

class ScrollableRow extends StatelessWidget {
  const ScrollableRow(
    this.children, {
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            spacer(context),
            ...ListUtils.insertBetween(children, spacer(context)),
            spacer(context),
          ],
        ),
      );

  SizedBox spacer(final BuildContext context) =>
      SizedBox(width: HorizontalBodyPadding.size(context));
}
