import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../config.dart';
import '../../plugins/app_lifecycle.dart';
import '../../plugins/helpers/http_download.dart';
import '../../plugins/helpers/screen.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/router.dart';
import '../../plugins/translator/translator.dart';
import '../../plugins/updater/updater.dart';

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> with RouteAware {
  final ValueNotifier<String> status =
      ValueNotifier<String>(Translator.t.initializing());

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(Duration.zero, () async {
      if (!AppLifecycle.ready) {
        await AppLifecycle.initialize();

        final PlatformUpdater? updater = Updater.getUpdater();
        if (updater != null && !kDebugMode) {
          status.value = Translator.t.checkingForUpdates();

          final List<UpdateInfo> updates = await updater.getUpdates();
          final UpdateInfo? update = updater.filterUpdate(updates);
          if (update != null) {
            updater.progress.subscribe((final UpdaterEvent x) {
              switch (x.event) {
                case UpdaterEvents.downloading:
                  final DownloadProgress casted = x.data as DownloadProgress;
                  status.value = Translator.t.downloadingVersion(
                    update.version,
                    '${casted.downloaded / 1000000}Mb',
                    '${casted.total / 1000000}Mb',
                    '${casted.percent}%',
                  );
                  break;

                case UpdaterEvents.extracting:
                  status.value = Translator.t.unpackingVersion(update.version);
                  break;

                case UpdaterEvents.starting:
                  status.value = Translator.t.updatingToVersion(update.version);
                  break;
              }
            });

            try {
              await updater.install(update);

              status.value = Translator.t.restartingApp();

              Screen.close();
              exit(0);
            } catch (err) {
              status.value = Translator.t.failedToUpdate(err.toString());
            }
          }
        }

        status.value = Translator.t.startingApp();
        await Future<void>.delayed(const Duration(seconds: 2));
      }

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
              SizedBox(
                height: remToPx(0.5),
              ),
              ValueListenableBuilder<String?>(
                valueListenable: status,
                builder: (
                  final BuildContext context,
                  final String? status,
                  final Widget? child,
                ) =>
                    Text(
                  status ?? ' ',
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            ],
          ),
        ),
      );
}
