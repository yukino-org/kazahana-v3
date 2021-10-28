import 'dart:convert';
import 'package:extensions/utils/http.dart';
import 'package:http/http.dart' as http;
import '../../../database/database.dart';
import '../../../helpers/pkce_challenge.dart';
import '../../../helpers/querystring.dart';

class MyAnimeListTokenInfo {
  MyAnimeListTokenInfo({
    required final this.accessToken,
    required final this.tokenType,
    required final this.refreshToken,
    required final this.expiresIn,
  });

  factory MyAnimeListTokenInfo.fromURL(final String url) {
    final QueryString queries = QueryString(url.split('#')[1]);
    return MyAnimeListTokenInfo(
      accessToken: queries.get('access_token'),
      tokenType: queries.get('token_type'),
      refreshToken: queries.get('refresh_token'),
      expiresIn: int.parse(queries.get('expires_in')),
    );
  }

  factory MyAnimeListTokenInfo.fromJson(final Map<dynamic, dynamic> json) =>
      MyAnimeListTokenInfo(
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
  MyAnimeListTokenInfo? token;
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

    token = MyAnimeListTokenInfo.fromJson(<dynamic, dynamic>{
      ...parsed,
      'expires_in':
          DateTime.now().millisecondsSinceEpoch + (parsed['expires_in'] as int),
    });
  }

  Future<bool> saveToken() async {
    if (token != null) {
      final CredentialsSchema creds = CredentialsBox.get();
      creds.myanimelist = token;
      await CredentialsBox.save(creds);
      return true;
    }

    return false;
  }

  Future<bool> deleteToken() async {
    final CredentialsSchema creds = CredentialsBox.get();
    creds.myanimelist = token = null;
    await CredentialsBox.save(creds);
    return true;
  }

  String getOauthURL() {
    _pkce ??= PKCEChallenge.generate();
    return Uri.encodeFull(
      '$baseURL/oauth2/authorize?response_type=code&client_id=$clientId&code_challenge_method=plain&code_challenge=${_pkce!.challenge}&redirect_uri=$redirectURL',
    );
  }

  bool hasTokenExpired() => DateTime.now().isBefore(token!.expiresAt);

  bool hasRefreshExpired() =>
      DateTime.now().microsecondsSinceEpoch <
      token!.expiresIn - 2592000000 - 3600000;

  bool isValidToken() => token != null && !hasRefreshExpired();
}
