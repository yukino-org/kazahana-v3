import 'package:path/path.dart' as path;
import 'package:tenka/tenka.dart';
import '../database/exports.dart';
import '../paths.dart';

abstract class TenkaManager {
  static late final TenkaRepository repository;

  static Future<void> initialize() async {
    await TenkaInternals.initialize(
      runtime: TenkaRuntimeOptions(
        http: TenkaRuntimeHttpClientOptions(
          ignoreSSLCertificate: SettingsDatabase.settings.ignoreSSLCertificate,
        ),
      ),
    );

    repository = TenkaRepository(
      resolver: const TenkaStoreURLResolver(),
      baseDir: path.join(Paths.docsDir.path, 'tenka'),
    );

    await repository.initialize();
  }

  static Future<T> getExtractor<T>(final TenkaMetadata metadata) async {
    final TenkaRuntimeInstance runtime = await TenkaRuntimeManager.create();
    await runtime.loadScriptCode('', appendDefinitions: true);
    await runtime.loadByteCode((metadata.source as TenkaBase64DS).data);
    return runtime.getExtractor<T>();
  }

  static Future<void> dispose() async {
    await TenkaInternals.dispose();
  }
}
