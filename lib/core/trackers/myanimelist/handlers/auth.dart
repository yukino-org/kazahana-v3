import 'dart:convert';
import 'package:extensions/utils/http.dart';
import 'package:http/http.dart' as http;
import '../../../../plugins/database/database.dart';
import '../../../../plugins/database/schemas/credentials/credentials.dart'
    as credentials_schema;
import '../../../../plugins/helpers/pkce_challenge.dart';
import '../../../../plugins/helpers/querystring.dart';

class TokenInfo {
  TokenInfo({
    required final this.accessToken,
    required final this.tokenType,
    required final this.refreshToken,
    required final this.expiresIn,
  });

  factory TokenInfo.fromURL(final String url) {
    final QueryString queries = QueryString(url.split('#')[1]);
    return TokenInfo(
      accessToken: queries.get('access_token'),
      tokenType: queries.get('token_type'),
      refreshToken: queries.get('refresh_token'),
      expiresIn: int.parse(queries.get('expires_in')),
    );
  }

  factory TokenInfo.fromJson(final Map<dynamic, dynamic> json) => TokenInfo(
        accessToken: json['access_token'] as String,
        tokenType: json['token_type'] as String,
        refreshToken: json['refresh_token'] as String,
        expiresIn: json['expires_in'] as int,
      );

  final String accessToken;
  final String tokenType;
  final String refreshToken;
  final int expiresIn;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'access_token': accessToken,
        'token_type': tokenType,
        'refresh_token': refreshToken,
        'expires_in': expiresIn,
      };

  DateTime get expiresAt => DateTime.fromMillisecondsSinceEpoch(expiresIn);
}

class Auth {
  Auth(this.clientId, this.redirectURL);

  final String baseURL = 'https://myanimelist.net/v1';

  final String clientId;
  final String redirectURL;
  TokenInfo? token;
  PKCEChallenge? _pkce;

  Future<void> authenticateFromCode(final String code) async {
    if (_pkce == null) {
      throw StateError('PKCE challenge was not generated');
    }

    await retrieveToken(<String, dynamic>{
      'grant_type': 'authorization_code',
      'code': code,
      'code_verifier': _pkce!.challenge,
    });
  }

  Future<void> authenticateFromRefreshCode() async {
    if (token == null) {
      throw StateError('No token was set');
    }

    await retrieveToken(<String, dynamic>{
      'refresh_token': token!.refreshToken,
      'grant_type': 'refresh_token',
    });
  }

  Future<void> retrieveToken(final Map<String, dynamic> body) async {
    final http.Response res = await http.post(
      Uri.parse(HttpUtils.tryEncodeURL('$baseURL/oauth2/token')),
      body: QueryString.stringify(<String, dynamic>{
        'client_id': clientId,
        'redirect_uri': redirectURL,
        ...body,
      }),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    final Map<dynamic, dynamic> parsed =
        json.decode(res.body) as Map<dynamic, dynamic>;

    token = TokenInfo.fromJson(<dynamic, dynamic>{
      ...parsed,
      'expires_in':
          DateTime.now().millisecondsSinceEpoch + (parsed['expires_in'] as int),
    });
  }

  Future<bool> saveToken() async {
    if (token != null) {
      final credentials_schema.CredentialsSchema creds = DataStore.credentials;
      creds.myanimelist = token!.toJson();
      creds.save();
      return true;
    }

    return false;
  }

  Future<bool> deleteToken() async {
    token = null;
    final credentials_schema.CredentialsSchema creds = DataStore.credentials;
    creds.myanimelist = null;
    creds.save();
    return true;
  }

  String getOauthURL() {
    _pkce ??= PKCEChallenge.generate();
    return Uri.encodeFull(
      '$baseURL/oauth2/authorize?response_type=code&client_id=$clientId&code_challenge_method=plain&code_challenge=${_pkce!.challenge}&redirect_uri=$redirectURL',
    );
  }

  bool isValidToken() =>
      token != null && DateTime.now().isBefore(token!.expiresAt);
}
