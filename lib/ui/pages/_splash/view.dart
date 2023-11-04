import 'package:kazahana/core/exports.dart';
import '../../exports.dart';

class UnderScoreSplashPage extends StatelessWidget {
  const UnderScoreSplashPage({
    super.key,
  });

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
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium!
                        .copyWith(fontFamily: Fonts.greatVibes),
                  ),
                  Text(
                    'v${AppMeta.version}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(context.r.scale(1)),
                child: Text(
                  AppMeta.yuki,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
          ],
        ),
      );
}
