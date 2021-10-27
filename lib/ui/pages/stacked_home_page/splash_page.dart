import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../config/app.dart';
import '../../../modules/app/lifecycle.dart';
import '../../../modules/helpers/http_download.dart';
import '../../../modules/helpers/logger.dart';
import '../../../modules/helpers/screen.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/state/loader.dart';
import '../../../modules/translator/translator.dart';
import '../../../modules/updater/updater.dart';

class Page extends StatefulWidget {
  const Page({
    required final this.refresh,
    final Key? key,
  }) : super(key: key);

  final void Function() refresh;

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> with InitialStateLoader {
  final ValueNotifier<String> status =
      ValueNotifier<String>(Translator.t.initializing());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    maybeLoad();
  }

  @override
  Future<void> load() async {
    if (!AppLifecycle.ready) {
      await AppLifecycle.initialize();

      final PlatformUpdater? updater = Updater.getUpdater();
      if (updater != null && kReleaseMode) {
        status.value = Translator.t.checkingForUpdates();

        final List<UpdateInfo> updates = await updater.getUpdates();
        final UpdateInfo? update = updater.filterUpdate(updates);
        if (update != null) {
          updater.progress.subscribe((final UpdaterEvent x) {
            switch (x.event) {
              case UpdaterEvents.downloading:
                final DownloadProgress casted = x.data as DownloadProgress;
                status.value = Translator.t.downloadingVersion(
                  'v${update.version.toString()}',
                  '${(casted.downloaded / 1048576).toStringAsFixed(1)}Mb',
                  '${(casted.total / 1048576).toStringAsFixed(1)}Mb',
                  '${casted.percent.toStringAsFixed(1)}%',
                );
                break;

              case UpdaterEvents.extracting:
                status.value = Translator.t
                    .unpackingVersion('v${update.version.toString()}');
                break;

              case UpdaterEvents.starting:
                status.value = Translator.t
                    .updatingToVersion('v${update.version.toString()}');
                break;
            }
          });

          try {
            final InstallResponse resp = await updater.install(update);

            if (resp.exit) {
              status.value = Translator.t.restartingApp();
              await Future<void>.delayed(const Duration(seconds: 3));

              await AppLifecycle.dispose();

              if (resp.beforeExit != null) {
                await resp.beforeExit!();
              }

              await Screen.close();
              exit(0);
            }
          } catch (err, stack) {
            Logger.of('splash_page').error('"Updater" failed: $err', stack);
            status.value = Translator.t.failedToUpdate(err.toString());
            await Future<void>.delayed(const Duration(seconds: 5));
          }
        }
      } else {
        status.value = Translator.t.startingApp();
      }

      await Future<void>.delayed(const Duration(seconds: 2));
      widget.refresh();
    }
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(remToPx(1)),
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
        ),
      );
}
