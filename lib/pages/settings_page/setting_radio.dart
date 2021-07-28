import 'package:flutter/material.dart';
import '../../core/utils.dart' as utils;
import '../../plugins/translator/translator.dart';

class SettingRadio<T extends Object> extends StatelessWidget {
  final String title;
  final String? dialogTitle;
  final IconData icon;
  final T value;
  final Map<T, String> labels;
  final void Function(T) onChanged;

  const SettingRadio({
    Key? key,
    required this.title,
    this.dialogTitle,
    required this.icon,
    required this.labels,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: utils.remToPx(1),
            vertical: utils.remToPx(0.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.subtitle1?.fontSize,
                    ),
                  ),
                  Text(
                    labels[value]!,
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.subtitle2?.fontSize,
                      color: Theme.of(context).textTheme.caption?.color,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                          ),
                          child: Text(
                            dialogTitle ?? title,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        ...labels
                            .map(
                              (x, name) => MapEntry(
                                x,
                                Material(
                                  type: MaterialType.transparency,
                                  child: RadioListTile(
                                    title: Text(name),
                                    value: x,
                                    groupValue: value,
                                    activeColor: Theme.of(context).primaryColor,
                                    onChanged: (val) {
                                      if (val != null &&
                                          val is T &&
                                          val != value) {
                                        onChanged(val);
                                        Navigator.of(context).pop();
                                      }
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
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: utils.remToPx(0.6),
                                  vertical: utils.remToPx(0.3),
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
                );
              });
        },
      ),
    );
  }
}
