import 'package:collection/collection.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import '../model.dart';

const String url = 'https://myanimelist.net';

class HomeResult {
  HomeResult({
    required final this.seasonName,
    required final this.seasonEntities,
    required final this.recentlyUpdated,
  });

  final String seasonName;
  final List<Entity> seasonEntities;
  final List<Entity> recentlyUpdated;
}

Future<HomeResult> extractHome() async {
  final http.Response resp = await http.get(Uri.parse(url));
  final dom.Document document = html.parse(resp.body);

  return HomeResult(
    seasonName: document
        .querySelector('#content .seasonal .widget-header .index_h2_seo')!
        .text,
    seasonEntities: document
        .querySelectorAll('#content .seasonal .widget-content .btn-anime .link')
        .map(
          (final dom.Element x) {
            final String? title = x.querySelector('.title')?.text.trim();
            final String? url = x.attributes['href'];
            final String? thumbnail =
                x.querySelector('img')?.attributes['data-src'];

            if (title != null && url != null && thumbnail != null) {
              return Entity(
                title: title,
                url: url,
                thumbnail: thumbnail,
                type: EntityTypes.anime,
                latest: null,
                score: null,
              );
            }
          },
        )
        .whereType<Entity>()
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
              return Entity(
                title: title,
                url: url,
                thumbnail: thumbnail,
                type: EntityTypes.anime,
                latest: latest,
                score: null,
              );
            }
          },
        )
        .whereType<Entity>()
        .toList(),
  );
}
