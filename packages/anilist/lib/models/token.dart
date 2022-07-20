class AnilistToken {
  const AnilistToken(this.json);

  factory AnilistToken.parseURL(final String url) {
    final Map<String, String> queries = Uri.splitQueryString(url.split('#')[1]);
    queries['expires_at'] = (DateTime.now().millisecondsSinceEpoch +
            (int.parse(queries['expires_in']!) * 1000))
        .toString();
    return AnilistToken(queries);
  }

  final Map<String, String> json;

  String get accessToken => json['access_token']!;
  String get tokenType => json['token_type']!;
  int get expiresIn => int.parse(json['expires_in']!);
  int get expiresAtRaw => int.parse(json['expires_at']!);
  DateTime get expiresAt => DateTime.fromMillisecondsSinceEpoch(expiresAtRaw);
}
