import 'package:kazahana/core/exports.dart';
import '../../../../exports.dart';

class MultiChoiceListTile<T> extends StatefulWidget {
  const MultiChoiceListTile({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
    this.secondary,
    super.key,
  });

  final Widget? secondary;
  final Widget title;
  final T value;
  final Map<T, Widget> items;
  final void Function(T) onChanged;

  @override
  State<MultiChoiceListTile<T>> createState() => _MultiChoiceListTileState<T>();
}

class _MultiChoiceListTileState<T> extends State<MultiChoiceListTile<T>> {
  final GlobalKey _initActiveOptionKey = GlobalKey();

  @override
  Widget build(final BuildContext context) => ListTile(
        leading: SizedBox(
          height: double.infinity,
          child: widget.secondary,
        ),
        title: widget.title,
        subtitle: widget.items[widget.value],
        onTap: () async {
          WidgetsBinding.instance.addPostFrameCallback((final _) {
            Scrollable.ensureVisible(
              _initActiveOptionKey.currentContext!,
              duration: AnimationDurations.defaultNormalAnimation,
            );
          });
          final T? value = await showModalBottomSheet<T>(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(context.r.scale(1)),
              ),
            ),
            builder: (final BuildContext context) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      left: context.r.scale(1),
                      right: context.r.scale(1),
                      top: context.r.scale(1),
                      bottom: context.r.scale(0.5),
                    ),
                    child: DefaultTextStyle(
                      style: Theme.of(context).textTheme.titleLarge!,
                      child: widget.title,
                    ),
                  ),
                  const Divider(),
                  ...widget.items
                      .map(
                        (final T key, final Widget value) =>
                            MapEntry<T, Widget>(
                          key,
                          RadioListTile<T>(
                            key: key == widget.value
                                ? _initActiveOptionKey
                                : null,
                            value: key,
                            groupValue: widget.value,
                            title: value,
                            onChanged: (final T? value) {
                              if (value == null) return;
                              Navigator.of(context).pop(value);
                            },
                          ),
                        ),
                      )
                      .values,
                ],
              ),
            ),
          );
          if (value != null && value != widget.value) {
            widget.onChanged(value);
          }
        },
      );
}
