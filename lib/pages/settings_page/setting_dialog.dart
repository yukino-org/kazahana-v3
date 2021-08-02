import 'package:flutter/material.dart';
import '../../core/utils.dart' as utils;
import '../../plugins/translator/translator.dart';
import './setting_tile.dart';

class SettingDialog extends StatelessWidget {
  final String title;
  final String? dialogTitle;
  final IconData icon;
  final String? subtitle;
  final Widget Function(BuildContext, void Function(void Function())) builder;

  const SettingDialog({
    Key? key,
    required this.title,
    this.dialogTitle,
    this.subtitle,
    required this.icon,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingTile(
        title: title,
        subtitle: subtitle,
        icon: icon,
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                          builder(context, setState),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
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
                },
              );
            },
          );
        });
  }
}
