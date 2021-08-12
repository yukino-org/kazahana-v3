import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart' show sha256;

String _randomString(final int length) {
  final List<String> chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
          .split('');

  return List<String>.generate(
    length,
    (final int i) => chars[Random().nextInt(chars.length)],
  ).join();
}

class PKCEChallenge {
  PKCEChallenge({
    required final this.verifier,
    required final this.challenge,
  });

  factory PKCEChallenge.generate([
    final int verifierLength = PKCEChallenge.defaultVerifierLength,
  ]) {
    final String verifier = _randomString(verifierLength);
    final List<int> sha = sha256.convert(utf8.encode(verifier)).bytes;
    final String challenge = base64
        .encode(sha)
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '');

    return PKCEChallenge(
      verifier: verifier,
      challenge: challenge,
    );
  }

  static const int defaultVerifierLength = 43;

  final String verifier;
  final String challenge;
}
