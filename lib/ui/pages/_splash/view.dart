import 'package:flutter/material.dart';
import '../../../core/exports.dart';

class UnderScoreSplashPage extends StatelessWidget {
  const UnderScoreSplashPage({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) => Scaffold(
        body: Stack(
          children: <Widget>[
            Align(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    AppMeta.name,
                    style: TextStyle(
                      fontFamily: Fonts.greatVibes,
                      fontSize:
                          Theme.of(context).textTheme.displayLarge!.fontSize! *
                              1.2,
                    ),
                  ),
                  Text(
                    'v${AppMeta.version}',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(rem(1)),
                child: Text(
                  AppMeta.yuki,
                  style: Theme.of(context)
                      .textTheme
                      .headline3!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
          ],
        ),
      );
}
