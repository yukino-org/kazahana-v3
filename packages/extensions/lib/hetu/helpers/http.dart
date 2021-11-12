import 'dart:io';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import '../../utils/http.dart';

const String httpDefinitions = '''
external fun fetch(data: Map); // (data: { method: 'get' | 'head' | 'post' | 'patch' | 'delete' | 'put', url: String, body: String? }) -> { body: String, status: int, headers: Map<String, String> }
external fun httpUserAgent() -> str;
external fun ensureURL(url: str) -> str;
''';

late Client http;

class HetuHttpClient {
  const HetuHttpClient({
    required final this.ignoreSSLCertificate,
  });

  final bool ignoreSSLCertificate;

  static late HetuHttpClient options;

  static void set(final HetuHttpClient options) {
    final HttpClient client = HttpClient();

    if (options.ignoreSSLCertificate) {
      client.badCertificateCallback =
          (final X509Certificate cert, final String host, final int port) =>
              true;
    }

    http = IOClient(client);
  }
}

Future<Map<dynamic, dynamic>> fetch(
  final Map<dynamic, dynamic> data,
) async {
  final String url = HttpUtils.tryEncodeURL(data['url'] as String);
  final Map<String, String> headers =
      (data['headers'] as Map<dynamic, dynamic>).cast<String, String>();
  final String? body = data['body'] as String?;

  final Response res;
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
