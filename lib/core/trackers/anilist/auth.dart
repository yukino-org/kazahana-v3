import '../../../plugins/helpers/pkce_challenge.dart';

class TokenInfo {
  TokenInfo({
    required final this.accessToken,
    required final this.tokenType,
    required final this.expiresIn,
  });

  factory TokenInfo.fromJson(final Map<dynamic, dynamic> json) => TokenInfo(
        accessToken: json['access_token'] as String,
        tokenType: json['token_type'] as String,
        expiresIn: json['expires_in'] as int,
      );

  final String accessToken;
  final String tokenType;
  final int expiresIn;

  Map<dynamic, dynamic> toJson(final TokenInfo token) => <dynamic, dynamic>{
        'access_token': accessToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
      };

  DateTime get expiresAt => DateTime.fromMillisecondsSinceEpoch(expiresIn);
}

class Auth {
  Auth(this.clientId);

  final String baseURL = 'https://anilist.co/api/v2';

  final String clientId;
  TokenInfo? token;
  PKCEChallenge? _pkce;

  void authorize(final TokenInfo _token) {
    token = TokenInfo(
      accessToken: _token.accessToken,
      tokenType: _token.tokenType,
      expiresIn:
          DateTime.now().millisecondsSinceEpoch + (_token.expiresIn * 1000),
    );
  }

  String getOauthURL() {
    _pkce ??= PKCEChallenge.generate();
    return Uri.encodeFull(
      '$baseURL/oauth/authorize?client_id=$clientId&response_type=token',
    );
  }

  bool isValidToken() =>
      token != null && token!.expiresIn > DateTime.now().microsecondsSinceEpoch;
}
