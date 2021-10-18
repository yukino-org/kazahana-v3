import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import '../../../config.dart';
import '../../helpers/http_download.dart';
import '../../helpers/local_server/server.dart';
import '../../helpers/logger.dart';
import '../updater.dart';

class LinuxAppImageUpdater with PlatformUpdater {
  static bool isSupported() =>
      Platform.isLinux &&
      Platform.environment.containsKey('APPIMAGE') &&
      RegExp(r'\.AppImage$').hasMatch(Platform.environment['APPIMAGE']!);

  @override
  UpdateInfo? filterUpdate(final List<UpdateInfo> updates) =>
      updates.firstWhereOrNull(
        (final UpdateInfo x) => x.path.endsWith('-linux.AppImage'),
      );

  @override
  Future<InstallResponse> install(final UpdateInfo update) async {
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

    final File currentExe = File(Platform.environment['APPIMAGE']!);
    await currentExe.delete(recursive: true);
    Logger.of('LinuxAppImageUpdater')
        .info('Removed current AppImage at: ${currentExe.path}');

    await currentExe.create(recursive: true);

    if (RegExp(r'v/\d+\.\d+\.\d+/').hasMatch(path.basename(currentExe.path))) {
      await currentExe
          .rename(path.join(path.dirname(currentExe.path), newExeName));
    }

    await newExeFile.copy(currentExe.path);
    await newExeFile.delete(recursive: true);

    final ProcessResult chmodRes = await Process.run(
      'chmod',
      <String>['755', currentExe.path],
      runInShell: true,
    );
    if (chmodRes.exitCode != 0) {
      throw Exception('Failed to make executable');
    }

    Logger.of('LinuxAppImageUpdater')
        .info('Copied and made AppImage executable at: ${currentExe.path}');

    return InstallResponse(
      exit: true,
      beforeExit: () async {
        await Process.start(
          currentExe.path,
          <String>[],
          runInShell: true,
          mode: ProcessStartMode.detached,
        );
        Logger.of('LinuxAppImageUpdater')
            .info('Spawned new app, waiting to close...');
      },
    );
  }
}
