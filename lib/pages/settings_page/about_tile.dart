import 'package:flutter/material.dart';
import '../../config.dart';
import '../../plugins/helpers/assets.dart';
import '../../plugins/helpers/ui.dart';

class AboutTile extends StatefulWidget {
  const AboutTile({
    final Key? key,
  }) : super(key: key);

  @override
  _AboutTileState createState() => _AboutTileState();
}

class _AboutTileState extends State<AboutTile> {
  PackageInfo pkgInfo = PackageInfo(
    appName: '',
    packageName: '',
    version: '0.0.0',
    buildNumber: '',
  );

  @override
  void initState() {
    super.initState();

    Config.pkg().then((final PackageInfo info) {
      pkgInfo = info;
    });
  }

  @override
  Widget build(final BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Wrap(
      children: <Widget>[
        Center(
          child: SizedBox(
            height: width > ResponsiveSizes.md ? remToPx(7) : remToPx(5),
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
                    text: Config.productName,
                    style: Theme.of(context).textTheme.headline5?.merge(
                          TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                  TextSpan(
                    text: '\nVersion: v${pkgInfo.version}',
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
