import 'dart:convert';
import 'package:extensions/extensions.dart' as extensions;
import 'package:flutter/cupertino.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import '../../../../components/trackers/detailed_item.dart';
import '../../../../pages/store_page/trackers_page/myanimelist_page/mangalist/edit_modal.dart';
import '../../../../plugins/helpers/stateful_holder.dart';
import '../../../../plugins/helpers/utils/string.dart';
import '../../detailed_info.dart';
import '../myanimelist.dart';

final Map<int, MangaListAdditionalDetail> _cacheDetails =
    <int, MangaListAdditionalDetail>{};

enum MangaListStatus {
  reading,
  completed,
  onHold,
  dropped,
  planToRead,
}

extension MangaListStatusUtils on MangaListStatus {
  String get status =>
      StringUtils.pascalToSnakeCase(toString().split('.').last);

  String get pretty => StringUtils.capitalize(
        StringUtils.pascalPretty(toString().split('.').last),
      );
}

class MangaListEntityProgress {
  MangaListEntityProgress({
    required final this.status,
    required final this.score,
    required final this.read,
    required final this.readVolumes,
    required final this.rereading,
    required final this.updatedAt,
  });

  factory MangaListEntityProgress.fromJson(final Map<dynamic, dynamic> json) =>
      MangaListEntityProgress(
        status: MangaListStatus.values.firstWhere(
          (final MangaListStatus x) => x.status == (json['status'] as String),
        ),
        score: json['score'] as int,
        read: json['num_chapters_read'] as int,
        readVolumes: json['num_volumes_read'] as int?,
        rereading: json['is_rereading'] as bool,
        updatedAt: json['updated_at'] as String,
      );

  final MangaListStatus status;
  final int score;
  final int read;
  final int? readVolumes;
  final bool rereading;
  final String updatedAt;
}

class MangaListAdditionalDetail {
  MangaListAdditionalDetail({
    required final this.synopsis,
    required final this.characters,
    required final this.totalChapters,
    required final this.totalVolumes,
  });

  final String synopsis;
  final List<Character> characters;
  final int? totalChapters;
  final int? totalVolumes;
}

class MangaListEntity {
  MangaListEntity({
    required final this.nodeId,
    required final this.title,
    required final this.mainPictureMedium,
    required final this.mainPictureLarge,
    required final this.status,
    required final this.details,
  });

  factory MangaListEntity.fromMangaListJson(final Map<dynamic, dynamic> json) =>
      MangaListEntity(
        nodeId: json['node']['id'] as int,
        title: json['node']['title'] as String,
        mainPictureMedium: json['node']['main_picture']['medium'] as String,
        mainPictureLarge: json['node']['main_picture']['large'] as String,
        status: MangaListEntityProgress.fromJson(
          json['list_status'] as Map<dynamic, dynamic>,
        ),
        details: null,
      );

  factory MangaListEntity.fromMangaDetails(final Map<dynamic, dynamic> json) =>
      MangaListEntity(
        nodeId: json['id'] as int,
        title: json['title'] as String,
        mainPictureMedium: json['main_picture']['medium'] as String,
        mainPictureLarge: json['main_picture']['large'] as String,
        status: json.containsKey('my_list_status')
            ? MangaListEntityProgress.fromJson(
                json['my_list_status'] as Map<dynamic, dynamic>,
              )
            : null,
        details: MangaListAdditionalDetail(
          synopsis: json['synopsis'] as String,
          totalChapters: json['num_chapters'] as int,
          totalVolumes: json['num_volumes'] as int,
          characters: <Character>[],
        ),
      );

  final int nodeId;
  final String title;
  final String mainPictureMedium;
  final String mainPictureLarge;
  MangaListEntityProgress? status;
  MangaListAdditionalDetail? details;

  Future<void> update({
    final MangaListStatus? status,
    final int? score,
    final int? read,
    final int? readVolumes,
    final bool? rereading,
  }) async {
    final String res = await MyAnimeListManager.request(
        MyAnimeListRequestMethods.put,
        '/manga/$nodeId/my_list_status', <String, dynamic>{
      if (status != null) 'status': status.status,
      if (rereading != null) 'is_rereading': rereading.toString(),
      if (score != null) 'score': score.toString(),
      if (read != null) 'num_chapters_read': read.toString(),
      if (readVolumes != null) 'num_volumes_read': readVolumes.toString(),
    });

    this.status = MangaListEntityProgress.fromJson(
      json.decode(res) as Map<dynamic, dynamic>,
    );
  }

  Future<void> fetch({
    final bool force = false,
  }) async {
    if (!force && _cacheDetails.containsKey(nodeId)) {
      details = _cacheDetails[nodeId];
      return;
    }

    final http.Response res = await http.get(
      Uri.parse('${MyAnimeListManager.webURL}/manga/$nodeId'),
      headers: <String, String>{
        'User-Agent': extensions.HttpUtils.userAgent,
      },
    );
    final dom.Document document = html.parse(res.body);

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

    details = MangaListAdditionalDetail(
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
      totalChapters: int.tryParse(metas['Chapters'] ?? ''),
      totalVolumes: int.tryParse(metas['Volumes'] ?? ''),
    );

    _cacheDetails[nodeId] = details!;
  }

  DetailedInfo toDetailedInfo() => DetailedInfo(
        title: title,
        description: details?.synopsis,
        type: extensions.ExtensionType.manga,
        thumbnail: mainPictureLarge,
        banner: null,
        status: status?.status.pretty,
        progress: Progress(
          progress: status?.read ?? 0,
          total: details?.totalChapters,
          startedAt: null,
          completedAt: null,
          volumes: VolumesProgress(
            progress: status?.readVolumes ?? 0,
            total: details?.totalVolumes,
          ),
        ),
        score: status?.score,
        repeated: null,
        characters: details?.characters ?? <Character>[],
      );

  Widget getDetailedPage(
    final BuildContext context, [
    final void Function()? onPlay,
  ]) =>
      _DetailedItemWrapper(
        item: this,
        onPlay: onPlay,
      );

  void applyChanges() {
    details = _cacheDetails[nodeId];
  }

  static Future<MangaListEntity> getFromNodeId(
    final int id,
  ) async =>
      (await tryGetFromNodeId(id))!;

  static Future<MangaListEntity?> tryGetFromNodeId(
    final int id,
  ) async {
    final String res = await MyAnimeListManager.request(
      MyAnimeListRequestMethods.get,
      '/manga/$id?fields=id,title,main_picture,synopsis,my_list_status,num_chapters,num_volumes',
    );

    final MangaListEntity entity = MangaListEntity.fromMangaDetails(
      json.decode(res) as Map<dynamic, dynamic>,
    );
    await entity.fetch();
    return entity;
  }
}

class _DetailedItemWrapper extends StatefulWidget {
  const _DetailedItemWrapper({
    required this.item,
    required this.onPlay,
    final Key? key,
  }) : super(key: key);

  final MangaListEntity item;
  final void Function()? onPlay;

  @override
  _DetailedItemWrapperState createState() => _DetailedItemWrapperState();
}

class _DetailedItemWrapperState extends State<_DetailedItemWrapper>
    with DidLoadStater {
  late bool fetched = widget.item.details != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    doLoadStateIfHasnt();
  }

  @override
  Future<void> load() async {
    if (!fetched) {
      await widget.item.fetch();

      if (mounted) {
        setState(() {
          fetched = true;
        });
      }
    }
  }

  @override
  Widget build(final BuildContext context) => DetailedItem(
        key: ValueKey<bool>(fetched),
        item: widget.item.toDetailedInfo(),
        onPlay: widget.onPlay,
        showBodyLoading: !fetched,
        onEdit: (final OnEditCallback cb) => EditModal(
          media: widget.item,
          callback: cb,
        ),
      );
}

Future<List<MangaListEntity>> getMangaList(
  final MangaListStatus status,
  final int page, [
  final int perPage = 100,
]) async {
  final String res = await MyAnimeListManager.request(
    MyAnimeListRequestMethods.get,
    '/users/@me/mangalist?fields=list_status&sort=list_updated_at&limit=$perPage&offset=${perPage * page}&status=${status.status}',
  );

  return ((json.decode(res) as Map<dynamic, dynamic>)['data'] as List<dynamic>)
      .cast<Map<dynamic, dynamic>>()
      .map(
        (final Map<dynamic, dynamic> x) => MangaListEntity.fromMangaListJson(x),
      )
      .toList();
}
