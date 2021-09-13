import 'package:hetu_script/hetu_script.dart';
import 'package:http/http.dart' as http;
import '../../utils/http.dart';

Future<void> fetch(
  final Map<dynamic, dynamic> data,
  final HTFunction cb,
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

  cb.call(
    positionalArgs: <dynamic>[
      <dynamic, dynamic>{
        'body': res.body,
        'status': res.statusCode,
        'headers': res.headers,
      },
    ],
  );
}
