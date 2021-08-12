import 'package:http/http.dart' as http;
import './model.dart';
import '../../../../plugins/helpers/utils/http.dart';
import '../model.dart' show getQuality, Qualities;

class StreamTapeCom extends SourceRetriever {
  @override
  final String name = 'StreamTape.com';

  @override
  final String baseURL = 'https://streamtape.com';

  late final Map<String, String> defaultHeaders = <String, String>{
    'User-Agent': HttpUtils.userAgent,
  };

  @override
  bool validate(final String url) =>
      RegExp(r'https?:\/\/streamtape\.com\/.*').hasMatch(url);

  @override
  Future<List<RetrievedSource>> fetch(final String url) async {
    try {
      final http.Response res = await http
          .get(
            Uri.parse(HttpUtils.tryEncodeURL(url)),
            headers: defaultHeaders,
          )
          .timeout(HttpUtils.extendedTimeout);
      final List<RetrievedSource> sources = <RetrievedSource>[];

      final String? match = RegExp(
        r'''id="videolink"[\s\S]+\.innerHTML[\s]+=[\s\S]+(id=[^'"]+)''',
      ).firstMatch(res.body)?[1];
      if (match != null) {
        sources.add(
          RetrievedSource(
            url: 'https://streamtape.com/get_video?$match',
            quality: getQuality(Qualities.unknown),
            headers: defaultHeaders,
          ),
        );
      }

      return sources;
    } catch (e) {
      rethrow;
    }
  }
}
