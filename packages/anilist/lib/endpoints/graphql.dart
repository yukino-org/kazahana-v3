import 'dart:convert';
import 'package:shared/http.dart' as http;
import 'package:utilx/utils.dart';

class AnilistGraphQLRequest {
  const AnilistGraphQLRequest({
    required this.query,
    this.variables = const <String, dynamic>{},
  });

  final String query;
  final Map<String, dynamic> variables;

  String get body => json.encode(<dynamic, dynamic>{
        'query': query,
        'variables': variables,
      });
}

class AnilistGraphQLResponse {
  const AnilistGraphQLResponse(this.response);

  final http.Response response;

  JsonMap get body => json.decode(response.body) as JsonMap;
  JsonMap? get data => body['data'] as JsonMap?;
  List<String>? get errors => body['errors'] != null
      ? castList<JsonMap>(body['errors'])
          .map((final JsonMap x) => x['message'] as String)
          .toList()
      : null;

  Exception get asException => throw Exception(
        'Request failed with status code ${response.statusCode} and errors: ${errors?.map((final String x) => '"$x"').join(', ') ?? '?'}',
      );
}

abstract class AnilistGraphQL {
  static final Uri baseURL = Uri.parse('https://graphql.anilist.co');
  static const Map<String, String> defaultHeaders = <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<AnilistGraphQLResponse> request(
    final AnilistGraphQLRequest request,
  ) async {
    final http.Response resp = await http.client.post(
      baseURL,
      headers: defaultHeaders,
      body: request.body,
    );
    return AnilistGraphQLResponse(resp);
  }
}
