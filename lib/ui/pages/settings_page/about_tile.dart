import 'package:flutter/material.dart';
import '../../../config/app.dart';
import '../../../modules/helpers/assets.dart';
import '../../../modules/helpers/ui.dart';

class AboutTile extends StatelessWidget {
  const AboutTile({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Column(
      children: <Widget>[
        SizedBox(
          height: remToPx(0.5),
        ),
        Center(
          child: SizedBox(
            height: width > ResponsiveSizes.md ? remToPx(6) : remToPx(5),
            child: Image.asset(Assets.yukinoIcon),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: remToPx(0.2),
          ),
          child: Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: Config.name,
                    style: Theme.of(context).textTheme.headline5?.merge(
                          TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                  TextSpan(
                    text: '\nVersion: v${Config.version}',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
