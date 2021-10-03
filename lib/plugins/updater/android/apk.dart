import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:ota_update/ota_update.dart';
import '../../helpers/http_download.dart';
import '../updater.dart';

class AndroidApkUpdater with PlatformUpdater {
  static bool isSupported() => Platform.isAndroid;

  @override
  UpdateInfo? filterUpdate(final List<UpdateInfo> updates) =>
      updates.firstWhereOrNull(
        (final UpdateInfo x) => x.path.endsWith('- android.apk'),
      );

  @override
  Future<bool> install(final UpdateInfo update) async {
    progress.dispatch(UpdaterEvent(UpdaterEvents.starting));

    final Completer<bool> future = Completer<bool>();

    final OtaUpdate ota = OtaUpdate();
    final double startedAt = DateTime.now().millisecondsSinceEpoch / 1000;

    final Stream<OtaEvent> otaEv = ota.execute(
      update.path,
      destinationFilename: update.path.split('/').last,
    );

    otaEv.listen((final OtaEvent ev) {
      switch (ev.status) {
        case OtaStatus.DOWNLOADING:
          {
            try {
              final int percent = int.parse(ev.value!);
              final int downloaded = (update.size * (percent / 100)).toInt();
              final double now = DateTime.now().millisecondsSinceEpoch / 1000;

              progress.dispatch(
                UpdaterEvent(
                  UpdaterEvents.downloading,
                  DownloadProgress(
                    downloaded,
                    update.size,
                    (now / startedAt) * downloaded,
                  ),
                ),
              );
            } catch (_) {}
            break;
          }

        case OtaStatus.INSTALLING:
          progress.dispatch(
            UpdaterEvent(
              UpdaterEvents.extracting,
            ),
          );
          future.complete(false);
          break;

        default:
          future.completeError('${ev.status.toString()}: ${ev.value}');
      }
    });

    return future.future;
  }
}
