import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import '../../../config.dart';
import '../../helpers/http_download.dart';
import '../../helpers/logger.dart';
import '../updater.dart';

class LinuxAppImageUpdater with PlatformUpdater {
  @override
  UpdateInfo? filterUpdate(final List<UpdateInfo> updates) =>
      updates.firstWhereOrNull(
        (final UpdateInfo x) => x.path.endsWith('- linux.AppImage'),
      );

  @override
  Future<void> install(final UpdateInfo update) async {
    progress.dispatch(UpdaterEvent(UpdaterEvents.starting));

    final String tmp = path.join(
      (await path_provider.getTemporaryDirectory()).path,
      Config.code,
    );
    final String newExeName = update.path.split('/').last;

    final File newExeFile = File(path.join(tmp, newExeName));

    if (!(await newExeFile.exists())) {
      final File partFile = File(path.join(tmp, '$newExeName.part'));

      if (!(await partFile.exists())) {
        await partFile.create(recursive: true);
      }

      final HttpDownload download =
          HttpDownload(Uri.parse(update.path), partFile);

      download.subscribe((final DownloadProgress x) {
        progress.dispatch(UpdaterEvent(UpdaterEvents.downloading, x));
      });

      await download.download();
      await partFile.rename(newExeFile.path);
      Logger.of('LinuxAppImageUpdater')
          .info('Update file created at: ${newExeFile.path}');
    } else {
      Logger.of('LinuxAppImageUpdater')
          .info('Update file found at: ${newExeFile.path}');
    }

    progress.dispatch(UpdaterEvent(UpdaterEvents.extracting));

    final File currentExe = File(Platform.resolvedExecutable);
    await currentExe.delete(recursive: true);
    await newExeFile.rename(currentExe.path);
    await Process.run(
      'chmod',
      <String>['a+x', currentExe.path],
      runInShell: true,
    );

    await Process.start(
      currentExe.path,
      <String>[],
      runInShell: true,
      mode: ProcessStartMode.detached,
    );
    Logger.of('LinuxAppImageUpdater')
        .info('Spawned new app, waiting to close...');
  }
}
