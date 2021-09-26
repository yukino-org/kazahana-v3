import 'package:flutter/material.dart';
import '../../config.dart';
import '../../plugins/app_lifecycle.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/router.dart';

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> with RouteAware {
  final ValueNotifier<String?> status = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(Duration.zero, () async {
      await AppLifecycle.initialize();
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pushNamed(RouteNames.home);
      }
    });
  }

  @override
  void didPopNext() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    print('couldnt pop');
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                Config.name,
                style: Theme.of(context).textTheme.headline3?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'v${Config.version}',
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: Theme.of(context).textTheme.caption?.color,
                    ),
              ),
              SizedBox(
                height: remToPx(2),
              ),
              SizedBox(
                width: remToPx(6),
                child: LinearProgressIndicator(
                  backgroundColor: Theme.of(context).cardColor,
                  minHeight: remToPx(0.12),
                ),
              ),
            ],
          ),
        ),
      );
}
