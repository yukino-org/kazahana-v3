import 'package:http/http.dart' as http;
import '../../utils/http.dart';

const String httpDefinitions = '''
external fun fetch(data: Map); // (data: { method: 'get' | 'head' | 'post' | 'patch' | 'delete' | 'put', url: String, body: String? }) -> { body: String, status: int, headers: Map<String, String> }
external fun httpUserAgent() -> str;
external fun ensureURL(url: str) -> str;
''';

Future<Map<dynamic, dynamic>> fetch(
  final Map<dynamic, dynamic> data,
) async {
  final String url = HttpUtils.tryEncodeURL(data['url'] as String);
  final Map<String, String> headers =
      (data['headers'] as Map<dynamic, dynamic>).cast<String, String>();
  final String? body = data['body'] as String?;

  final http.Response res;
  switch (data['method']) {
    case 'get':
      res = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(HttpUtils.timeout);
      break;

    case 'head':
      res = await http
          .head(Uri.parse(url), headers: headers)
          .timeout(HttpUtils.timeout);
      break;

    case 'post':
      res = await http
          .post(Uri.parse(url), body: body, headers: headers)
          .timeout(HttpUtils.timeout);
      break;

    case 'patch':
      res = await http
          .patch(Uri.parse(url), body: body, headers: headers)
          .timeout(HttpUtils.timeout);
      break;

    case 'delete':
      res = await http
          .delete(Uri.parse(url), body: body, headers: headers)
          .timeout(HttpUtils.timeout);
      break;

    case 'put':
      res = await http
          .put(Uri.parse(url), body: body, headers: headers)
          .timeout(HttpUtils.timeout);
      break;

    default:
      throw AssertionError('Unknown "method": ${data['method']}');
  }

  return <dynamic, dynamic>{
    'body': res.body,
    'status': res.statusCode,
    'headers': res.headers,
  };
}

String httpUserAgent() => HttpUtils.userAgent;

const String Function(String) ensureURL = HttpUtils.ensureURL;
