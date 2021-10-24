import 'package:flutter/material.dart';
import '../../../../plugins/database/database.dart' show DataBox;
import '../../../../plugins/database/schemas/cache/cache.dart' as cache_schema;
import '../../../../plugins/helpers/assets.dart';
import '../../../../plugins/translator/translator.dart';
import '../../../models/tracker_provider.dart';
import '../myanimelist.dart' as myanimelist;

final Map<int, myanimelist.MangaListEntity> _cache =
    <int, myanimelist.MangaListEntity>{};

final TrackerProvider<MangaProgress> manga = TrackerProvider<MangaProgress>(
  name: Translator.t.myAnimeList(),
  image: Assets.myAnimeListLogo,
  getComputed: (
    final String title,
    final String plugin, {
    final bool force = false,
  }) async {
    final cache_schema.CacheSchema? cache =
        DataBox.cache.get('myanimelist-manga-$title-$plugin');

    try {
      if (!force && cache != null) {
        final myanimelist.MangaListEntity mediaList = _cache[cache.value] ??
            await myanimelist.MangaListEntity.getFromNodeId(
              cache.value as int,
            );

        return ResolvedTrackerItem(
          title: mediaList.title,
          image: mediaList.mainPictureMedium,
          info: mediaList,
        );
      }
    } catch (_) {}

    final List<myanimelist.SearchMangaEntity> media =
        await myanimelist.searchManga(title);
    if (media.isNotEmpty) {
      final myanimelist.MangaListEntity mediaList =
          await myanimelist.MangaListEntity.getFromNodeId(
        media.first.nodeId,
      );

      await DataBox.cache.put(
        'myanimelist-manga-$title-$plugin',
        cache_schema.CacheSchema(
          media.first.nodeId,
          0,
        ),
      );

      return ResolvedTrackerItem(
        title: mediaList.title,
        image: mediaList.mainPictureMedium,
        info: mediaList,
      );
    }
  },
  getComputables: (final String title) async {
    final List<myanimelist.SearchMangaEntity> media =
        await myanimelist.searchManga(title);

    return media
        .map(
          (final myanimelist.SearchMangaEntity x) => ResolvableTrackerItem(
            id: x.nodeId.toString(),
            title: x.title,
            image: x.mainPictureMedium,
          ),
        )
        .toList();
  },
  resolveComputed: (
    final String title,
    final String plugin,
    final ResolvableTrackerItem item,
  ) async {
    final myanimelist.MangaListEntity mediaList =
        await myanimelist.MangaListEntity.getFromNodeId(
      int.parse(item.id),
    );

    await DataBox.cache.put(
      'myanimelist-manga-$title-$plugin',
      cache_schema.CacheSchema(
        mediaList.nodeId,
        0,
      ),
    );

    _cache[mediaList.nodeId] = mediaList;

    return ResolvedTrackerItem(
      title: mediaList.title,
      image: mediaList.mainPictureMedium,
      info: mediaList,
    );
  },
  updateComputed: (
    final ResolvedTrackerItem media,
    final MangaProgress progress,
  ) async {
    final myanimelist.MangaListEntity info =
        media.info as myanimelist.MangaListEntity;
    final myanimelist.MangaListStatus status =
        progress.chapters >= (info.status?.read ?? -1) &&
                info.details?.finishedPublishing == true
            ? myanimelist.MangaListStatus.completed
            : myanimelist.MangaListStatus.reading;

    final int chapters = progress.chapters;
    final int? volumes = progress.volume;

    final bool repeating =
        progress.chapters == 1 && (info.status?.read ?? -1) > 1;

    int changes = 0;
    final List<List<dynamic>> changables = <List<dynamic>>[
      <dynamic>[info.status?.status, status],
      <dynamic>[info.status?.read, chapters],
      <dynamic>[info.status?.readVolumes, volumes],
      <dynamic>[info.status?.rereading, repeating],
    ];

    for (final List<dynamic> item in changables) {
      if (item.first != item.last) {
        changes += 1;
      }
    }

    if (changes > 0) {
      await info.update(
        status: status,
        read: chapters,
        readVolumes: volumes,
        rereading: repeating,
      );

      _cache[info.nodeId] = info;
      onItemUpdateChangeNotifier.dispatch(media);
    }
  },
  isLoggedIn: myanimelist.MyAnimeListManager.auth.isValidToken,
  isEnabled: (final String title, final String plugin) =>
      !DataBox.cache.containsKey('myanimelist-manga-$title-$plugin-disabled'),
  setEnabled:
      (final String title, final String plugin, final bool isEnabled) async {
    isEnabled
        ? await DataBox.cache
            .delete('myanimelist-manga-$title-$plugin-disabled')
        : await DataBox.cache.put(
            'myanimelist-manga-$title-$plugin-disabled',
            cache_schema.CacheSchema(
              null,
              0,
            ),
          );
  },
  getDetailedPage: (
    final BuildContext context,
    final ResolvedTrackerItem item,
  ) {
    final myanimelist.MangaListEntity info =
        item.info as myanimelist.MangaListEntity;

    return info.getDetailedPage(
      context,
      Navigator.of(context).pop,
    );
  },
  isItemSameKind: (
    final ResolvedTrackerItem current,
    final ResolvedTrackerItem unknown,
  ) {
    if (current.info is myanimelist.MangaListEntity &&
        unknown.info is myanimelist.MangaListEntity) {
      final myanimelist.MangaListEntity a =
          current.info as myanimelist.MangaListEntity;
      final myanimelist.MangaListEntity b =
          unknown.info as myanimelist.MangaListEntity;

      return a.nodeId == b.nodeId;
    }

    return false;
  },
);
