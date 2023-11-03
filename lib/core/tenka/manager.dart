import 'package:path/path.dart' as path;
import 'package:tenka/tenka.dart';
import '../database/exports.dart';
import '../paths.dart';

abstract class TenkaManager {
  static late final TenkaRepository repository;
  static final Map<String, dynamic> _extractors = <String, dynamic>{};

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

    // await repository.initialize();
  }

  static Future<T> getExtractor<T>(final TenkaMetadata metadata) async {
    if (!_extractors.containsKey(metadata.id)) {
      final BeizeProgramConstant program = BeizeProgramConstant.deserialize(
        (metadata.source as TenkaBase64DS).data,
      );
      final TenkaRuntimeInstance runtime =
          await TenkaRuntimeManager.create(program);
      final T extractor;
      if (T is AnimeExtractor) {
        extractor = await runtime.getAnimeExtractor() as T;
      } else if (T is MangaExtractor) {
        extractor = await runtime.getMangaExtractor() as T;
      } else {
        throw UnsupportedError('Invalid extractor type: $T');
      }
      _extractors[metadata.id] = extractor;
    }

    return _extractors[metadata.id] as T;
  }
}
