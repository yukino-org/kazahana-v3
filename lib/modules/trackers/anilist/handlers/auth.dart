import '../../../database/database.dart';
import '../../../database/schemas/credentials/credentials.dart'
    as credentials_schema;
import '../../../helpers/querystring.dart';

class AniListTokenInfo {
  AniListTokenInfo({
    required final this.accessToken,
    required final this.tokenType,
    required final this.expiresIn,
  });

  factory AniListTokenInfo.fromURL(final String url) {
    final QueryString queries = QueryString(url.split('#')[1]);
    return AniListTokenInfo(
      accessToken: queries.get('access_token'),
      tokenType: queries.get('token_type'),
      expiresIn: int.parse(queries.get('expires_in')),
    );
  }

  factory AniListTokenInfo.fromJson(final Map<dynamic, dynamic> json) =>
      AniListTokenInfo(
        accessToken: json['access_token'] as String,
        tokenType: json['token_type'] as String,
        expiresIn: json['expires_in'] as int,
      );

  final String accessToken;
  final String tokenType;
  final int expiresIn;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'access_token': accessToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
      };

  DateTime get expiresAt => DateTime.fromMillisecondsSinceEpoch(expiresIn);
}

class AniListAuth {
  AniListAuth(this.clientId);

  final String baseURL = 'https://anilist.co/api/v2';

  final String clientId;
  AniListTokenInfo? token;

  void authorize(final AniListTokenInfo _token) {
    token = AniListTokenInfo(
      accessToken: _token.accessToken,
      tokenType: _token.tokenType,
      expiresIn:
          DateTime.now().millisecondsSinceEpoch + (_token.expiresIn * 1000),
    );
  }

  Future<bool> saveToken() async {
    if (token != null) {
      final credentials_schema.CredentialsSchema creds = DataStore.credentials;
      creds.anilist = token!.toJson();
      creds.save();
      return true;
    }

    return false;
  }

  Future<bool> deleteToken() async {
    token = null;
    final credentials_schema.CredentialsSchema creds = DataStore.credentials;
    creds.anilist = null;
    creds.save();
    return true;
  }

  String getOauthURL() => Uri.encodeFull(
        '$baseURL/oauth/authorize?client_id=$clientId&response_type=token',
      );

  bool isValidToken() =>
      token != null && DateTime.now().isBefore(token!.expiresAt);
}
