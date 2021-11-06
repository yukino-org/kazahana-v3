import 'package:flutter/material.dart';
import './base.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/translator/translator.dart';

class MaterialDialogTile extends StatelessWidget {
  const MaterialDialogTile({
    required final this.title,
    required final this.icon,
    required final this.dialogBuilder,
    final Key? key,
    final this.dialogTitle,
    final this.subtitle,
    final this.actions,
  }) : super(key: key);

  final Widget title;
  final Widget? dialogTitle;
  final Widget? subtitle;
  final Widget icon;
  final Widget Function(BuildContext, StateSetter) dialogBuilder;
  final List<Widget>? actions;

  @override
  Widget build(final BuildContext context) => MaterialTile(
        icon: icon,
        title: title,
        subtitle: subtitle,
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
                          child: DefaultTextStyle(
                            style: Theme.of(context).textTheme.headline6!,
                            child: dialogTitle ?? title,
                          ),
                        ),
                        SizedBox(
                          height: remToPx(0.3),
                        ),
                        dialogBuilder(context, setState),
                        if (actions?.isNotEmpty ?? false)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: remToPx(0.7),
                              ),
                              child: actions != null
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: actions!,
                                    )
                                  : InkWell(
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
                                            color:
                                                Theme.of(context).primaryColor,
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
