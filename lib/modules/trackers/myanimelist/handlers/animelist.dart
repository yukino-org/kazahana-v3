import 'dart:convert';
import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import '../../../../ui/components/trackers/detailed_item.dart';
import '../../../../ui/pages/store_page/trackers_page/myanimelist_page/animelist/edit_modal.dart';
import '../../../state/hooks.dart';
import '../../../utils/utils.dart';
import '../../provider.dart';
import '../myanimelist.dart';

final Map<int, MyAnimeListAnimeListAdditionalDetail> _cacheDetails =
    <int, MyAnimeListAnimeListAdditionalDetail>{};

enum MyAnimeListAnimeListStatus {
  watching,
  completed,
  onHold,
  dropped,
  planToWatch,
}

extension MyAnimeListAnimeListStatusUtils on MyAnimeListAnimeListStatus {
  String get status =>
      StringUtils.pascalToSnakeCase(toString().split('.').last);

  String get pretty => StringUtils.capitalize(
        StringUtils.pascalPretty(toString().split('.').last),
      );
}

class MyAnimeListAnimeListProgress {
  MyAnimeListAnimeListProgress({
    required final this.status,
    required final this.score,
    required final this.watched,
    required final this.rewatching,
    required final this.updatedAt,
  });

  factory MyAnimeListAnimeListProgress.fromJson(
    final Map<dynamic, dynamic> json,
  ) =>
      MyAnimeListAnimeListProgress(
        status: MyAnimeListAnimeListStatus.values.firstWhere(
          (final MyAnimeListAnimeListStatus x) =>
              x.status == (json['status'] as String),
        ),
        score: json['score'] as int,
        watched: json['num_episodes_watched'] as int,
        rewatching: json['is_rewatching'] as bool,
        updatedAt: json['updated_at'] as String,
      );

  final MyAnimeListAnimeListStatus status;
  final int score;
  final int watched;
  final bool rewatching;
  final String updatedAt;
}

class MyAnimeListAnimeListAdditionalDetail {
  MyAnimeListAnimeListAdditionalDetail({
    required final this.synopsis,
    required final this.characters,
    required final this.totalEpisodes,
  });

  final String synopsis;
  final List<Character> characters;
  final int? totalEpisodes;
}

class MyAnimeListAnimeList {
  MyAnimeListAnimeList({
    required final this.nodeId,
    required final this.title,
    required final this.mainPictureMedium,
    required final this.mainPictureLarge,
    required final this.status,
    required final this.details,
  });

  factory MyAnimeListAnimeList.fromAnimeListJson(
    final Map<dynamic, dynamic> json,
  ) =>
      MyAnimeListAnimeList(
        nodeId: json['node']['id'] as int,
        title: json['node']['title'] as String,
        mainPictureMedium: json['node']['main_picture']['medium'] as String,
        mainPictureLarge: json['node']['main_picture']['large'] as String,
        status: MyAnimeListAnimeListProgress.fromJson(
          json['list_status'] as Map<dynamic, dynamic>,
        ),
        details: null,
      );

  factory MyAnimeListAnimeList.fromAnimeDetails(
    final Map<dynamic, dynamic> json,
  ) =>
      MyAnimeListAnimeList(
        nodeId: json['id'] as int,
        title: json['title'] as String,
        mainPictureMedium: json['main_picture']['medium'] as String,
        mainPictureLarge: json['main_picture']['large'] as String,
        status: json.containsKey('my_list_status')
            ? MyAnimeListAnimeListProgress.fromJson(
                json['my_list_status'] as Map<dynamic, dynamic>,
              )
            : null,
        details: MyAnimeListAnimeListAdditionalDetail(
          synopsis: json['synopsis'] as String,
          totalEpisodes: json['num_episodes'] as int,
          characters: <Character>[],
        ),
      );

  final int nodeId;
  final String title;
  final String mainPictureMedium;
  final String mainPictureLarge;
  MyAnimeListAnimeListProgress? status;
  MyAnimeListAnimeListAdditionalDetail? details;

  Future<void> update({
    final MyAnimeListAnimeListStatus? status,
    final int? score,
    final int? watched,
    final bool? rewatching,
  }) async {
    final String res = await MyAnimeListManager.request(
        MyAnimeListRequestMethods.put,
        '/anime/$nodeId/my_list_status', <String, dynamic>{
      if (status != null) 'status': status.status,
      if (rewatching != null) 'is_rewatching': rewatching.toString(),
      if (score != null) 'score': score.toString(),
      if (watched != null) 'num_watched_episodes': watched.toString(),
    });

    this.status = MyAnimeListAnimeListProgress.fromJson(
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

    final MyAnimeListAnimeList entity =
        await MyAnimeListSearchAnime.scrapeFromNodeId(nodeId);
    details = _cacheDetails[nodeId] = entity.details!;
  }

  DetailedInfo toDetailedInfo() => DetailedInfo(
        title: title,
        description: details?.synopsis,
        type: ExtensionType.anime,
        thumbnail: mainPictureLarge,
        banner: null,
        status: status?.status.pretty,
        progress: Progress(
          progress: status?.watched ?? 0,
          total: details?.totalEpisodes,
          startedAt: null,
          completedAt: null,
          volumes: null,
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
        readonly: !MyAnimeListManager.auth.isValidToken(),
      );

  void applyChanges() {
    details = _cacheDetails[nodeId];
  }

  static Future<MyAnimeListAnimeList> getFromNodeId(
    final int id,
  ) async =>
      (await tryGetFromNodeId(id))!;

  static Future<MyAnimeListAnimeList?> tryGetFromNodeId(
    final int id,
  ) async {
    if (MyAnimeListManager.auth.isValidToken()) {
      final String res = await MyAnimeListManager.request(
        MyAnimeListRequestMethods.get,
        '/anime/$id?fields=id,title,main_picture,synopsis,my_list_status,num_episodes',
      );

      final MyAnimeListAnimeList entity = MyAnimeListAnimeList.fromAnimeDetails(
        json.decode(res) as Map<dynamic, dynamic>,
      );
      await entity.fetch();
      return entity;
    }

    return MyAnimeListSearchAnime.scrapeFromNodeId(id);
  }

  static Future<List<MyAnimeListAnimeList>> getAnimeList(
    final MyAnimeListAnimeListStatus status,
    final int page, [
    final int perPage = 100,
  ]) async {
    final String res = await MyAnimeListManager.request(
      MyAnimeListRequestMethods.get,
      '/users/@me/animelist?fields=list_status&sort=list_updated_at&limit=$perPage&offset=${perPage * page}&status=${status.status}',
    );

    return ((json.decode(res) as Map<dynamic, dynamic>)['data']
            as List<dynamic>)
        .cast<Map<dynamic, dynamic>>()
        .map(
          (final Map<dynamic, dynamic> x) =>
              MyAnimeListAnimeList.fromAnimeListJson(x),
        )
        .toList();
  }
}

class _DetailedItemWrapper extends StatefulWidget {
  const _DetailedItemWrapper({
    required final this.item,
    required final this.onPlay,
    final this.readonly = false,
    final Key? key,
  }) : super(key: key);

  final MyAnimeListAnimeList item;
  final void Function()? onPlay;
  final bool readonly;

  @override
  _DetailedItemWrapperState createState() => _DetailedItemWrapperState();
}

class _DetailedItemWrapperState extends State<_DetailedItemWrapper>
    with HooksMixin {
  late bool fetched = widget.item.details != null;

  @override
  void initState() {
    super.initState();

    onReady(() async {
      if (!fetched) {
        await widget.item.fetch();

        if (mounted) {
          setState(() {
            fetched = true;
          });
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    hookState.markReady();
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
        readonly: widget.readonly,
      );
}
