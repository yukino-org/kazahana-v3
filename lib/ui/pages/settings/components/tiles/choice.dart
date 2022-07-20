import '../../../../../core/exports.dart';

class MultiChoiceListTile<T> extends StatelessWidget {
  const MultiChoiceListTile({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
    this.secondary,
    final Key? key,
  }) : super(key: key);

  final Widget? secondary;
  final Widget title;
  final T value;
  final Map<T, Widget> items;
  final void Function(T) onChanged;

  @override
  Widget build(final BuildContext context) => ListTile(
        leading: SizedBox(
          height: double.infinity,
          child: secondary,
        ),
        title: title,
        subtitle: items[value],
        onTap: () async {
          final T? value = await showModalBottomSheet<T>(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(rem(1))),
            ),
            builder: (final BuildContext context) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      left: rem(1),
                      right: rem(1),
                      top: rem(1),
                      bottom: rem(0.5),
                    ),
                    child: DefaultTextStyle(
                      style: Theme.of(context).textTheme.headline6!,
                      child: title,
                    ),
                  ),
                  const Divider(),
                  ...items
                      .map(
                        (final T key, final Widget value) =>
                            MapEntry<T, Widget>(
                          key,
                          RadioListTile<T>(
                            value: key,
                            groupValue: this.value,
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
          if (value != null && value != this.value) {
            onChanged(value);
          }
        },
      );
}
