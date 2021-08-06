import 'package:http/http.dart' as http;
import '../../../utils.dart' as utils;
import './model.dart';
import '../model.dart' show getQuality, Qualities;

class StreamTapeCom extends SourceRetriever {
  @override
  final name = 'StreamTap.com';

  @override
  final baseURL = 'https://streamtape.com';

  late final Map<String, String> defaultHeaders = {
    'User-Agent': utils.Http.userAgent,
  };

  @override
  validate(url) => RegExp(r'https?:\/\/streamtape\.com\/.*').hasMatch(url);

  @override
  fetch(url) async {
    try {
      final res = await http
          .get(
            Uri.parse(utils.Fns.tryEncodeURL(url)),
            headers: defaultHeaders,
          )
          .timeout(utils.Http.extendedTimeout);
      final List<RetrievedSource> sources = [];

      final match = RegExp(
              r'''id="videolink"[\s\S]+\.innerHTML[\s]+=[\s\S]+(id=[^'"]+)''')
          .firstMatch(res.body)?[1];
      if (match != null) {
        sources.add(RetrievedSource(
          url: 'https://streamtape.com/get_video?$match',
          quality: getQuality(Qualities.unknown),
          headers: defaultHeaders,
        ));
      }

      return sources;
    } catch (e) {
      rethrow;
    }
  }
}
