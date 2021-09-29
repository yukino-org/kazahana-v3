import 'dart:io';
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
  Future<void> install(final UpdateInfo update) async {
    final String tmp = path.join(
      (await path_provider.getTemporaryDirectory()).path,
      Config.code,
    );
    final String baseDir = path.dirname(Platform.resolvedExecutable);

    final File zipFile = File(path.join(tmp, update.path.split('/').last));

    if (!(await zipFile.exists())) {
      await zipFile.create(recursive: true);
    }

    final HttpDownload download = HttpDownload(Uri.parse(update.path), zipFile);
    download.subscribe(progress.dispatch);

    await download.download();

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
