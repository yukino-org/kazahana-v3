import '../../model.dart';
import '../model.dart';

class RetrievedSource {
  RetrievedSource({
    required final this.url,
    required final this.quality,
    required final this.headers,
  });

  String url;
  Quality quality;
  Map<String, String> headers;
}

abstract class SourceRetriever extends BaseExtractor {
  bool validate(final String url);
  Future<List<RetrievedSource>> fetch(final String url);
}
