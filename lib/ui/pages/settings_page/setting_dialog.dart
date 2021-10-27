import 'package:flutter/material.dart';
import './setting_tile.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/translator/translator.dart';

class SettingDialog extends StatelessWidget {
  const SettingDialog({
    required final this.title,
    required final this.icon,
    required final this.builder,
    final this.dialogTitle,
    final this.subtitle,
    final Key? key,
  }) : super(key: key);

  final String title;
  final String? dialogTitle;
  final IconData icon;
  final String? subtitle;
  final Widget Function(BuildContext, StateSetter) builder;

  @override
  Widget build(final BuildContext context) => SettingTile(
        title: title,
        subtitle: subtitle,
        icon: icon,
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
                StatefulBuilder(
              builder: (
                final BuildContext context,
                final StateSetter setState,
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
                      mainAxisSize: MainAxisSize.min,
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
                        builder(context, setState),
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
            ),
          );
        },
      );
}
