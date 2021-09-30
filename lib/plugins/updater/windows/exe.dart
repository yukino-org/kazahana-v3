import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import '../../../config.dart';
import '../../helpers/http_download.dart';
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

echo Copy updated files
robocopy {{{ updatedDir }}} {{{ installDir }}} /s /e /purge

echo Running app
{{{ exePath }}}
''';

class WindowsExeUpdater with PlatformUpdater {
  @override
  UpdateInfo? filterUpdate(final List<UpdateInfo> updates) =>
      updates.firstWhereOrNull(
        (final UpdateInfo x) => x.path.endsWith('- windows.zip'),
      );

  @override
  Future<void> install(final UpdateInfo update) async {
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
      await partFile.rename(zipFile.path);
    }

    progress.dispatch(UpdaterEvent(UpdaterEvents.extracting));

    final String sevenZipPath = path.join(
      baseDir,
      'data/flutter_assets/assets/executables/7za.exe',
    );
    final String unzipPath = path.join(tmp);
    await Process.run(
      sevenZipPath,
      <String>['e', '"${zipFile.path}"', '-o"$unzipPath"', '-y'],
      runInShell: true,
    );

    final String batPath = path.join(tmp, 'updater.bat');
    final File batFile = File(batPath);

    if (!(await batFile.exists())) {
      await batFile.create(recursive: true);
    }

    await batFile.writeAsString(
      StringUtils.render(_template, <String, String>{
        'updatedDir': unzipPath,
        'installDir': baseDir,
        'exePath': Platform.resolvedExecutable,
        'exeName': path.basename(Platform.resolvedExecutable),
      }),
    );

    Process.run(
      'powershell',
      <String>[
        'start',
        '-verb',
        'runas',
        batFile.path,
      ],
      includeParentEnvironment: false,
      runInShell: true,
    );
  }
}
