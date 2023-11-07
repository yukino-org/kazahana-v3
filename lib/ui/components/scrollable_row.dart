import 'package:kazahana/core/exports.dart';
import 'package:kazahana/ui/components/exports.dart';
import 'body_padding.dart';

class ScrollableRow extends StatefulWidget {
  const ScrollableRow(
    this.children, {
    super.key,
  });

  final List<Widget> children;

  @override
  State<ScrollableRow> createState() => _ScrollableRowState();
}

class _ScrollableRowState extends State<ScrollableRow> {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  SizedBox buildSpacer(final BuildContext context) =>
      SizedBox(width: HorizontalBodyPadding.paddingValue(context));

  @override
  Widget build(final BuildContext context) => DraggableScrollConfiguration(
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildSpacer(context),
              ...ListUtils.insertBetween(
                widget.children,
                buildSpacer(context),
              ),
              buildSpacer(context),
            ],
          ),
        ),
      );
}
