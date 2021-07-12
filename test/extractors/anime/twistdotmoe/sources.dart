import 'dart:convert';
import 'package:test/test.dart';
import 'package:yukino_app/core/extractor/animes/twistdoemot.dart';

const episodeURL = 'https://twist.moe/a/manyuu-hikenchou/12';

Future<void> main() async {
  test('Search', () async {
    final client = TwistMoe();
    final res = await client.getSources(episodeURL);

    // ignore: avoid_print
    print(const JsonEncoder.withIndent('  ').convert(res));

    expect(res.isEmpty, false);
  });
}
