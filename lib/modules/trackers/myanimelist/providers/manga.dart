import 'package:flutter/material.dart';
import '../../../database/database.dart';
import '../../../database/schemas/cache/cache.dart';
import '../../../helpers/assets.dart';
import '../../../translator/translator.dart';
import '../../provider.dart';
import '../myanimelist.dart';

final Map<int, MyAnimeListMangaList> _cache = <int, MyAnimeListMangaList>{};

final TrackerProvider<MangaProgress> mangaProvider =
    TrackerProvider<MangaProgress>(
  name: Translator.t.myAnimeList(),
  image: Assets.myAnimeListLogo,
  getComputed: (
    final String title,
    final String plugin, {
    final bool force = false,
  }) async {
    final CacheSchema? cache =
        DataBox.cache.get('myanimelist-manga-$title-$plugin');

    try {
      if (!force && cache != null) {
        final MyAnimeListMangaList mediaList = _cache[cache.value] ??
            await MyAnimeListMangaList.getFromNodeId(
              cache.value as int,
            );

        return ResolvedTrackerItem(
          title: mediaList.title,
          image: mediaList.mainPictureMedium,
          info: mediaList,
        );
      }
    } catch (_) {}

    final List<MyAnimeListSearchManga> media =
        await MyAnimeListSearchManga.searchManga(title);
    if (media.isNotEmpty) {
      final MyAnimeListMangaList mediaList =
          await MyAnimeListMangaList.getFromNodeId(
        media.first.nodeId,
      );

      await DataBox.cache.put(
        'myanimelist-manga-$title-$plugin',
        CacheSchema(media.first.nodeId, 0),
      );

      return ResolvedTrackerItem(
        title: mediaList.title,
        image: mediaList.mainPictureMedium,
        info: mediaList,
      );
    }
  },
  getComputables: (final String title) async {
    final List<MyAnimeListSearchManga> media =
        await MyAnimeListSearchManga.searchManga(title);

    return media
        .map(
          (final MyAnimeListSearchManga x) => ResolvableTrackerItem(
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
    final MyAnimeListMangaList mediaList =
        await MyAnimeListMangaList.getFromNodeId(
      int.parse(item.id),
    );

    await DataBox.cache.put(
      'myanimelist-manga-$title-$plugin',
      CacheSchema(mediaList.nodeId, 0),
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
    final MyAnimeListMangaList info = media.info as MyAnimeListMangaList;
    final MyAnimeListMangaListStatus status =
        progress.chapters >= (info.status?.read ?? -1)
            ? MyAnimeListMangaListStatus.completed
            : MyAnimeListMangaListStatus.reading;

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
  isLoggedIn: MyAnimeListManager.auth.isValidToken,
  isEnabled: (final String title, final String plugin) =>
      !DataBox.cache.containsKey('myanimelist-manga-$title-$plugin-disabled'),
  setEnabled:
      (final String title, final String plugin, final bool isEnabled) async {
    isEnabled
        ? await DataBox.cache
            .delete('myanimelist-manga-$title-$plugin-disabled')
        : await DataBox.cache.put(
            'myanimelist-manga-$title-$plugin-disabled',
            CacheSchema(null, 0),
          );
  },
  getDetailedPage: (
    final BuildContext context,
    final ResolvedTrackerItem item,
  ) {
    final MyAnimeListMangaList info = item.info as MyAnimeListMangaList;

    return info.getDetailedPage(
      context,
      Navigator.of(context).pop,
    );
  },
  isItemSameKind: (
    final ResolvedTrackerItem current,
    final ResolvedTrackerItem unknown,
  ) {
    if (current.info is MyAnimeListMangaList &&
        unknown.info is MyAnimeListMangaList) {
      final MyAnimeListMangaList a = current.info as MyAnimeListMangaList;
      final MyAnimeListMangaList b = unknown.info as MyAnimeListMangaList;

      return a.nodeId == b.nodeId;
    }

    return false;
  },
);
