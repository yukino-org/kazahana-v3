import 'package:http/http.dart' as http;
import './model.dart';
import '../../../../plugins/helpers/utils/http.dart';
import '../model.dart' show getQuality, Qualities;

class SbPlayOrg extends SourceRetriever {
  @override
  final String name = 'SbPlay.org';

  @override
  final String baseURL = 'https://sbplay.org';

  late final Map<String, String> defaultHeaders = <String, String>{
    'User-Agent': HttpUtils.userAgent,
  };

  @override
  bool validate(final String url) =>
      RegExp(r'https?:\/\/sbplay\.org\/.*').hasMatch(url);

  @override
  Future<List<RetrievedSource>> fetch(final String url) async {
    try {
      final http.Response res = await http
          .get(
            Uri.parse(HttpUtils.tryEncodeURL(url.replaceFirst('embed-', 'd/'))),
            headers: defaultHeaders,
          )
          .timeout(HttpUtils.timeout);

      final List<RetrievedSource> sources = <RetrievedSource>[];
      for (final RegExpMatch match
          in RegExp(r'onclick="download_video\((.*?)\)"')
              .allMatches(res.body)) {
        final List<String>? parsed = match[1] != null
            ? RegExp("'(.*?)'")
                .allMatches(match[1]!)
                .map((final RegExpMatch x) => x[1])
                .whereType<String>()
                .toList()
            : null;

        if (parsed != null && parsed.length == 3) {
          final String code = parsed[0], mode = parsed[1], hash = parsed[2];
          final http.Response res = await http
              .get(
                Uri.parse(
                  HttpUtils.tryEncodeURL(
                    '$baseURL/dl?op=download_orig&id=$code&mode=$mode&hash=$hash',
                  ),
                ),
                headers: defaultHeaders,
              )
              .timeout(HttpUtils.timeout);

          final String? src =
              RegExp(r'<a href="(.*?)">Direct Download Link<\/a>')
                  .firstMatch(res.body)?[1];
          if (src != null) {
            sources.add(
              RetrievedSource(
                url: src,
                quality: getQuality(Qualities.unknown),
                headers: defaultHeaders,
              ),
            );
          }
        }
      }

      return sources;
    } catch (e) {
      rethrow;
    }
  }
}
