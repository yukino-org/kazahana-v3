import 'package:flutter/material.dart';
import '../../../../../../modules/helpers/ui.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    required final this.icon,
    required final this.label,
    required final this.onPressed,
    required final this.enabled,
    final Key? key,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final void Function() onPressed;
  final bool enabled;

  @override
  Widget build(final BuildContext context) => OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: remToPx(0.2),
          ),
          side: BorderSide(
            color: Colors.white.withOpacity(0.3),
          ),
          backgroundColor: Colors.black.withOpacity(0.5),
        ),
        onPressed: enabled ? onPressed : null,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: remToPx(0.4),
            vertical: remToPx(0.2),
          ),
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  size: Theme.of(context).textTheme.subtitle1?.fontSize,
                  color: Colors.white,
                ),
                SizedBox(
                  width: remToPx(0.2),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.subtitle1?.fontSize,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
