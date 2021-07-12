import 'dart:convert';
import 'package:test/test.dart';
import 'package:yukino_app/core/extractor/animes/twistdoemot.dart';

void main() {
  test('Search', () async {
    final client = TwistMoe();
    final res = await client.search('mayo chiki');

    // ignore: avoid_print
    print(const JsonEncoder.withIndent('  ')
        .convert(res.map((x) => x.toJson()).toList()));

    expect(res.isEmpty, false);
  });
}
