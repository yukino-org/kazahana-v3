import 'dart:convert';
import 'package:shared/http.dart' as http;
import 'package:utilx/utils.dart';
import '../models/exports.dart';

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
  List<String>? get errors => hasErrors
      ? castList<JsonMap>(body['errors'])
          .map((final JsonMap x) => x['message'] as String)
          .toList()
      : null;

  bool get hasErrors => body['errors'] != null;
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

  static AnilistToken? token;
  static void Function()? onTokenExpired;
  static final Map<String, String> additionalHeaders = <String, String>{};

  static void updateClient({
    required final AnilistToken? token,
    required final void Function()? onTokenExpired,
    required final Map<String, String>? additionalHeaders,
  }) {
    AnilistGraphQL.token = token;
    AnilistGraphQL.onTokenExpired = onTokenExpired;
    if (additionalHeaders != null) {
      AnilistGraphQL.additionalHeaders.addAll(additionalHeaders);
    }
  }

  static Future<AnilistGraphQLResponse> request(
    final AnilistGraphQLRequest request, {
    final bool retryOnExpiredSession = true,
  }) async {
    final http.Response resp = await http.client.post(
      baseURL,
      headers: <String, String>{
        ...defaultHeaders,
        ...additionalHeaders,
        if (token != null)
          'Authorization': '${token!.tokenType} ${token!.accessToken}',
      },
      body: request.body,
    );
    final AnilistGraphQLResponse parsed = AnilistGraphQLResponse(resp);
    if (parsed.hasErrors &&
        retryOnExpiredSession &&
        parsed.errors!.contains('Invalid token')) {
      token = null;
      return AnilistGraphQL.request(request);
    }
    return parsed;
  }
}
