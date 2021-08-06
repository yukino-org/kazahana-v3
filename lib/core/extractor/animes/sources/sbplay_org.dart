import 'package:http/http.dart' as http;
import '../../../utils.dart' as utils;
import './model.dart';
import '../model.dart' show getQuality, Qualities;

class SbPlayOrg extends SourceRetriever {
  @override
  final name = 'SbPlay.org';

  @override
  final baseURL = 'https://sbplay.org';

  late final Map<String, String> defaultHeaders = {
    'User-Agent': utils.Http.userAgent,
  };

  @override
  validate(url) => RegExp(r'https?:\/\/sbplay\.org\/.*').hasMatch(url);

  @override
  fetch(url) async {
    try {
      url = url.replaceFirst("embed-", "d/");

      final res = await http
          .get(
            Uri.parse(utils.Fns.tryEncodeURL(url)),
            headers: defaultHeaders,
          )
          .timeout(utils.Http.timeout);

      final List<RetrievedSource> sources = [];
      for (final match in RegExp(r'onclick="download_video\((.*?)\)"')
          .allMatches(res.body)) {
        final parsed = match[1] != null
            ? RegExp(r"'(.*?)'")
                .allMatches(match[1]!)
                .map((x) => x[1])
                .whereType<String>()
                .toList()
            : null;
        if (parsed != null && parsed.length == 3) {
          final code = parsed[0], mode = parsed[1], hash = parsed[2];
          final res = await http
              .get(
                Uri.parse(utils.Fns.tryEncodeURL(
                  '$baseURL/dl?op=download_orig&id=$code&mode=$mode&hash=$hash',
                )),
                headers: defaultHeaders,
              )
              .timeout(utils.Http.timeout);
          final src = RegExp(r'<a href="(.*?)">Direct Download Link<\/a>')
              .firstMatch(res.body)?[1];
          if (src != null) {
            sources.add(RetrievedSource(
              url: src,
              quality: getQuality(Qualities.unknown),
              headers: defaultHeaders,
            ));
          }
        }
      }

      return sources;
    } catch (e) {
      rethrow;
    }
  }
}
