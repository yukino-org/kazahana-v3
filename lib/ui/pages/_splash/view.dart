import 'package:flutter/material.dart';
import '../../../core/exports.dart';

class UnderScoreSplashPage extends StatelessWidget {
  const UnderScoreSplashPage({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                AppMeta.name,
                style: TextStyle(
                  fontFamily: Fonts.greatVibes,
                  fontSize:
                      Theme.of(context).textTheme.displayLarge!.fontSize! * 1.2,
                ),
              ),
              SizedBox(height: rem(1.5)),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2.5,
                child: LinearProgressIndicator(minHeight: rem(0.1)),
              ),
            ],
          ),
        ),
      );
}
