import 'package:flutter/material.dart';
import '../../../database/database.dart';
import '../../../helpers/assets.dart';
import '../../../translator/translator.dart';
import '../../provider.dart';
import '../myanimelist.dart';

final Map<int, MyAnimeListAnimeList> _cache = <int, MyAnimeListAnimeList>{};

final TrackerProvider<AnimeProgress> animeProvider =
    TrackerProvider<AnimeProgress>(
  name: Translator.t.myAnimeList(),
  image: Assets.myAnimeListLogo,
  getComputed: (
    final String title,
    final String plugin, {
    final bool force = false,
  }) async {
    final CacheSchema? cache = CacheBox.get('myanimelist-anime-$title-$plugin');

    try {
      if (!force && cache != null) {
        final MyAnimeListAnimeList mediaList = _cache[cache.value] ??
            await MyAnimeListAnimeList.getFromNodeId(
              cache.value as int,
            );

        return ResolvedTrackerItem(
          title: mediaList.title,
          image: mediaList.mainPictureMedium,
          info: mediaList,
        );
      }
    } catch (_) {}

    final List<MyAnimeListSearchAnime> media =
        await MyAnimeListSearchAnime.searchAnime(title);
    if (media.isNotEmpty) {
      final MyAnimeListAnimeList mediaList =
          await MyAnimeListAnimeList.getFromNodeId(
        media.first.nodeId,
      );

      await CacheBox.saveKV(
        'myanimelist-anime-$title-$plugin',
        media.first.nodeId,
        0,
      );

      return ResolvedTrackerItem(
        title: mediaList.title,
        image: mediaList.mainPictureMedium,
        info: mediaList,
      );
    }
  },
  getComputables: (final String title) async {
    final List<MyAnimeListSearchAnime> media =
        await MyAnimeListSearchAnime.searchAnime(title);

    return media
        .map(
          (final MyAnimeListSearchAnime x) => ResolvableTrackerItem(
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
    final MyAnimeListAnimeList mediaList =
        await MyAnimeListAnimeList.getFromNodeId(
      int.parse(item.id),
    );

    await CacheBox.saveKV(
      'myanimelist-anime-$title-$plugin',
      mediaList.nodeId,
      0,
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
    final AnimeProgress progress,
  ) async {
    final MyAnimeListAnimeList info = media.info as MyAnimeListAnimeList;
    final MyAnimeListAnimeListStatus status =
        progress.episodes >= (info.status?.watched ?? -1)
            ? MyAnimeListAnimeListStatus.completed
            : MyAnimeListAnimeListStatus.watching;

    final int episodes = progress.episodes;

    final bool repeating =
        progress.episodes == 1 && (info.status?.watched ?? -1) > 1;

    int changes = 0;
    final List<List<dynamic>> changables = <List<dynamic>>[
      <dynamic>[info.status?.status, status],
      <dynamic>[info.status?.watched, episodes],
      <dynamic>[info.status?.rewatching, repeating],
    ];

    for (final List<dynamic> item in changables) {
      if (item.first != item.last) {
        changes += 1;
      }
    }

    if (changes > 0) {
      await info.update(
        status: status,
        watched: episodes,
        rewatching: repeating,
      );

      _cache[info.nodeId] = info;
      onItemUpdateChangeNotifier.dispatch(media);
    }
  },
  isLoggedIn: MyAnimeListManager.auth.isValidToken,
  isEnabled: (final String title, final String plugin) =>
      CacheBox.get('myanimelist-anime-$title-$plugin-disabled') == null,
  setEnabled:
      (final String title, final String plugin, final bool isEnabled) async {
    isEnabled
        ? CacheBox.delete('myanimelist-anime-$title-$plugin-disabled')
        : await CacheBox.saveKV(
            'myanimelist-anime-$title-$plugin-disabled',
            null,
            0,
          );
  },
  getDetailedPage: (
    final BuildContext context,
    final ResolvedTrackerItem item,
  ) {
    final MyAnimeListAnimeList info = item.info as MyAnimeListAnimeList;

    return info.getDetailedPage(
      context,
      Navigator.of(context).pop,
    );
  },
  isItemSameKind: (
    final ResolvedTrackerItem current,
    final ResolvedTrackerItem unknown,
  ) {
    if (current.info is MyAnimeListAnimeList &&
        unknown.info is MyAnimeListAnimeList) {
      final MyAnimeListAnimeList a = current.info as MyAnimeListAnimeList;
      final MyAnimeListAnimeList b = unknown.info as MyAnimeListAnimeList;

      return a.nodeId == b.nodeId;
    }

    return false;
  },
);
