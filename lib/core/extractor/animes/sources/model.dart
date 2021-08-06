import '../../model.dart';
import '../model.dart';

class RetrievedSource {
  String url;
  Quality quality;
  Map<String, String> headers;

  RetrievedSource({
    required this.url,
    required this.quality,
    this.headers = const {},
  });
}

abstract class SourceRetriever extends BaseExtractor {
  bool validate(String url);
  Future<List<RetrievedSource>> fetch(String url);
}
