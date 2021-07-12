import 'dart:convert';
import 'package:test/test.dart';
import 'package:yukino_app/core/extractor/animes/twistdoemot.dart';

const animeURL = 'https://twist.moe/a/manyuu-hikenchou';

void main() {
  test('Search', () async {
    final client = TwistMoe();
    final res = await client.getInfo(animeURL);

    // ignore: avoid_print
    print(const JsonEncoder.withIndent('  ').convert(res.toJson()));

    expect(res.url, animeURL);
  });
}
