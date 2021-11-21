import 'package:collection/collection.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:utilx/utilities/utils.dart';
import '../myanimelist.dart';

enum MyAnimeListHomeContentType {
  anime,
  manga,
  ova,
  ona,
  lightNovel,
}

extension MyAnimeListHomeContentTypeUtils on MyAnimeListHomeContentType {
  String get type => StringUtils.capitalize(
        toString().split('.').last.replaceAllMapped(
              RegExp('[A-Z]'),
              (final Match match) => ' ${match.group(0)}',
            ),
      );
}

class MyAnimeListHomeContent {
  MyAnimeListHomeContent({
    required final this.title,
    required final this.url,
    required final this.rawThumbnail,
    required final this.type,
    required final this.latest,
    required final this.score,
    final this.tags = const <String>[],
    final this.description,
    final this.time,
  });

  final String title;
  final String url;
  final String rawThumbnail;
  final MyAnimeListHomeContentType type;
  final String? latest;
  final int? score;
  final List<String> tags;
  final String? description;
  final String? time;

  String get thumbnail {
    final RegExpMatch? match =
        RegExp(r'\/images.*\.(jpg|jpeg|png|webp)').firstMatch(rawThumbnail);

    if (match != null) {
      return 'https://cdn.myanimelist.net${match.group(0)}';
    }

    return rawThumbnail;
  }

  int get id => int.parse(
        RegExp(r'https:\/\/myanimelist\.net\/(anime|manga)\/(\d+)')
            .firstMatch(url)!
            .group(2)!,
      );
}

class MyAnimeListHome {
  MyAnimeListHome({
    required final this.seasonName,
    required final this.seasonEntities,
    required final this.recentlyUpdated,
  });

  final String seasonName;
  final List<MyAnimeListHomeContent> seasonEntities;
  final List<MyAnimeListHomeContent> recentlyUpdated;

  static Future<MyAnimeListHome> extractHome() async {
    final http.Response resp =
        await http.get(Uri.parse(MyAnimeListManager.webURL));
    final dom.Document document = html.parse(resp.body);

    return MyAnimeListHome(
      seasonName: document
          .querySelector('#content .seasonal .widget-header .index_h2_seo')!
          .text,
      seasonEntities: document
          .querySelectorAll(
            '#content .seasonal .widget-content .btn-anime .link',
          )
          .map(
            (final dom.Element x) {
              final String? title = x.querySelector('.title')?.text.trim();
              final String? url = x.attributes['href'];
              final String? thumbnail =
                  x.querySelector('img')?.attributes['data-src'];

              if (title != null && url != null && thumbnail != null) {
                return MyAnimeListHomeContent(
                  title: title,
                  url: url,
                  rawThumbnail: thumbnail,
                  type: MyAnimeListHomeContentType.anime,
                  latest: null,
                  score: null,
                );
              }
            },
          )
          .whereType<MyAnimeListHomeContent>()
          .toList(),
      recentlyUpdated: document
          .querySelectorAll(
            '#content .latest_episode_video .widget-content .btn-anime',
          )
          .map(
            (final dom.Element x) {
              final String? title = x.querySelector('.external-link')?.text;
              final String? url =
                  x.querySelector('.external-link a')?.attributes['href'];
              final String? thumbnail =
                  x.querySelector('img')?.attributes['data-src'];
              final String? latest = x
                  .querySelector('.title.di-b')
                  ?.children
                  .firstOrNull
                  ?.text
                  .replaceFirst('Episode', '')
                  .trim();

              if (title != null && url != null && thumbnail != null) {
                return MyAnimeListHomeContent(
                  title: title,
                  url: url,
                  rawThumbnail: thumbnail,
                  type: MyAnimeListHomeContentType.anime,
                  latest: latest,
                  score: null,
                );
              }
            },
          )
          .whereType<MyAnimeListHomeContent>()
          .toList(),
    );
  }
}
