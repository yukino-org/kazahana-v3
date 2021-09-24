import 'package:flutter/material.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/translator/translator.dart';

class SettingRadio<T extends Object> extends StatelessWidget {
  const SettingRadio({
    required final this.title,
    required final this.icon,
    required final this.labels,
    required final this.value,
    required final this.onChanged,
    final Key? key,
    final this.dialogTitle,
  }) : super(key: key);

  final String title;
  final String? dialogTitle;
  final IconData icon;
  final T value;
  final Map<T, String> labels;
  final void Function(T) onChanged;

  @override
  Widget build(final BuildContext context) => Material(
        type: MaterialType.transparency,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: remToPx(2.1),
                  child: Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(width: remToPx(0.8)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.subtitle1?.fontSize,
                      ),
                    ),
                    Text(
                      labels[value]!,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.subtitle2?.fontSize,
                        color: Theme.of(context).textTheme.caption?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: () async {
            await showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel:
                  MaterialLocalizations.of(context).modalBarrierDismissLabel,
              pageBuilder: (
                final BuildContext context,
                final Animation<double> a1,
                final Animation<double> a2,
              ) =>
                  SafeArea(
                child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      vertical: remToPx(0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: remToPx(1.1),
                          ),
                          child: Text(
                            dialogTitle ?? title,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        SizedBox(
                          height: remToPx(0.3),
                        ),
                        ...labels
                            .map(
                              (final T x, final String name) =>
                                  MapEntry<T, Widget>(
                                x,
                                Material(
                                  type: MaterialType.transparency,
                                  child: RadioListTile<T>(
                                    title: Text(name),
                                    value: x,
                                    groupValue: value,
                                    activeColor: Theme.of(context).primaryColor,
                                    onChanged: (final T? val) {
                                      if (val != null &&
                                          val is T &&
                                          val != value) {
                                        onChanged(val);
                                      }
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ),
                            )
                            .values
                            .toList(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: remToPx(0.7),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: remToPx(0.6),
                                  vertical: remToPx(0.3),
                                ),
                                child: Text(
                                  Translator.t.close(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
}
