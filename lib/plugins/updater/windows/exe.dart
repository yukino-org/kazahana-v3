import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import '../../../config.dart';
import '../../helpers/archive.dart';
import '../../helpers/http_download.dart';
import '../../helpers/logger.dart';
import '../../helpers/utils/string.dart';
import '../updater.dart';

const String _template = '''
@echo off

title Yukino - Updater

:LOOP
tasklist | find /i "{{{ exeName }}}" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE
) ELSE (
  ECHO Waiting for the app to close...
  Timeout /T 5 /Nobreak
  GOTO LOOP
)

:CONTINUE

echo Delete old files
rmdir "{{{ installDir }}}" /s /q

echo Copy updated files
robocopy "{{{ updatedDir }}}" "{{{ installDir }}}" /s /e

echo Spawn updated app
start {{{ exePath }}}

echo Finished updating
''';

class WindowsExeUpdater with PlatformUpdater {
  static bool isSupported() =>
      Platform.isWindows &&
      RegExp(r'\.exe$').hasMatch(Platform.resolvedExecutable);

  @override
  UpdateInfo? filterUpdate(final List<UpdateInfo> updates) =>
      updates.firstWhereOrNull(
        (final UpdateInfo x) => x.path.endsWith('-windows.zip'),
      );

  @override
  Future<InstallResponse> install(final UpdateInfo update) async {
    progress.dispatch(UpdaterEvent(UpdaterEvents.starting));

    final String tmp = path.join(
      (await path_provider.getTemporaryDirectory()).path,
      Config.code,
    );
    final String baseDir = path.dirname(Platform.resolvedExecutable);
    final String zipName = update.path.split('/').last;

    final File zipFile = File(path.join(tmp, zipName));

    if (!(await zipFile.exists())) {
      final File partFile = File(path.join(tmp, '$zipName.part'));

      if (!(await partFile.exists())) {
        await partFile.create(recursive: true);
      }

      final HttpDownload download =
          HttpDownload(Uri.parse(update.path), partFile);

      download.subscribe((final DownloadProgress x) {
        progress.dispatch(UpdaterEvent(UpdaterEvents.downloading, x));
      });

      await download.download();
      await zipFile.create(recursive: true);
      await partFile.rename(zipFile.path);
      Logger.of('WindowsExeUpdater')
          .info('Update file created at: ${zipFile.path}');
    } else {
      Logger.of('WindowsExeUpdater')
          .info('Update file found at: ${zipFile.path}');
    }

    progress.dispatch(UpdaterEvent(UpdaterEvents.extracting));

    final Directory unzipPath =
        Directory(path.join(tmp, zipName.replaceFirst(RegExp(r'.zip$'), '')));

    if (await unzipPath.exists()) {
      await unzipPath.delete(recursive: true);
    }

    await unzipPath.create(recursive: true);
    await extractArchive(ExtractArchiveConfig(zipFile.path, unzipPath.path));
    Logger.of('WindowsExeUpdater').info('Unzipped into: $unzipPath');

    final String batPath = path.join(tmp, 'updater.bat');
    final File batFile = File(batPath);

    if (!(await batFile.exists())) {
      await batFile.create(recursive: true);
    }

    await batFile.writeAsString(
      StringUtils.render(_template, <String, String>{
        'updatedDir': unzipPath.path,
        'installDir': baseDir,
        'exePath': Platform.resolvedExecutable,
        'exeName': path.basename(Platform.resolvedExecutable),
      }),
    );
    Logger.of('WindowsExeUpdater').info('Created bat at: ${batFile.path}');

    return InstallResponse(
      exit: true,
      beforeExit: () async {
        await Process.start(
          'powershell.exe',
          <String>[
            'start',
            '-verb',
            'runas',
            batFile.path,
          ],
          runInShell: true,
          mode: ProcessStartMode.detached,
        );
        Logger.of('WindowsExeUpdater')
            .info('Spawned bat, waiting for restart...');
      },
    );
  }
}
