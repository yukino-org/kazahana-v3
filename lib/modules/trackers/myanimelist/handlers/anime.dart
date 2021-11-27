import 'dart:convert';
import 'package:extensions/extensions.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import '../../provider.dart';
import '../myanimelist.dart';

class MyAnimeListSearchAnime {
  MyAnimeListSearchAnime({
    required final this.nodeId,
    required final this.title,
    required final this.mainPictureMedium,
    required final this.mainPictureLarge,
  });

  factory MyAnimeListSearchAnime.fromJson(final Map<dynamic, dynamic> json) =>
      MyAnimeListSearchAnime(
        nodeId: json['node']['id'] as int,
        title: json['node']['title'] as String,
        mainPictureMedium: json['node']['main_picture'] != null
            ? json['node']['main_picture']['medium'] as String
            : null,
        mainPictureLarge: json['node']['main_picture'] != null
            ? json['node']['main_picture']['large'] as String
            : null,
      );

  final int nodeId;
  final String title;
  final String? mainPictureMedium;
  final String? mainPictureLarge;

  static Future<List<MyAnimeListSearchAnime>> searchAnime(
    final String terms,
  ) async {
    final String res = await MyAnimeListManager.request(
      MyAnimeListRequestMethods.get,
      '/anime?q=${Uri.encodeQueryComponent(terms)}&limit=10',
    );

    final Map<dynamic, dynamic> decoded =
        json.decode(res) as Map<dynamic, dynamic>;

    return decoded.containsKey('data')
        ? (decoded['data'] as List<dynamic>)
            .cast<Map<dynamic, dynamic>>()
            .map(
              (final Map<dynamic, dynamic> x) =>
                  MyAnimeListSearchAnime.fromJson(x),
            )
            .toList()
        : <MyAnimeListSearchAnime>[];
  }

  static Future<MyAnimeListAnimeList> scrapeFromNodeId(
    final int nodeId,
  ) async {
    final http.Response resp = await http.get(
      Uri.parse('${MyAnimeListManager.webURL}/anime/$nodeId'),
      headers: <String, String>{
        'User-Agent': HttpUtils.userAgent,
      },
    );
    final dom.Document document = html.parse(resp.body);

    final Map<String, String> metas = <String, String>{};
    document
        .querySelector('#content .borderClass > div')
        ?.children
        .forEach((final dom.Element x) {
      if (x.classes.contains('spaceit_pad')) {
        final RegExpMatch? match =
            RegExp(r'([^:]+):([\S\s]+)').firstMatch(x.text);
        if (match != null) {
          metas[match.group(1)!.trim()] = match.group(2)!.trim();
        }
      }
    });

    final String thumbnail =
        document.querySelector('[itemprop=image]')!.attributes['data-src']!;

    return MyAnimeListAnimeList(
      nodeId: nodeId,
      title: document.querySelector('.title-name')!.text.trim(),
      mainPictureMedium: thumbnail,
      mainPictureLarge: thumbnail,
      status: null,
      details: MyAnimeListAnimeListAdditionalDetail(
        synopsis: document.querySelector('[itemprop="description"]')!.text,
        characters: document
            .querySelectorAll(
          '.detail-characters-list > div > table > tbody > tr',
        )
            .map((final dom.Element x) {
          final List<dom.Element> tds = x.querySelectorAll('td');

          return Character(
            name: tds[1].querySelector('a')!.text.trim(),
            role: tds[1].querySelector('small')!.text.trim(),
            image: tds[0].querySelector('img')!.attributes['data-src']!.trim(),
          );
        }).toList(),
        totalEpisodes: int.tryParse(metas['Episodes'] ?? ''),
      ),
    );
  }
}
