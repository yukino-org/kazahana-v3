import 'package:flutter/material.dart';
import '../../../../plugins/database/database.dart' show DataBox;
import '../../../../plugins/database/schemas/cache/cache.dart' as cache_schema;
import '../../../../plugins/helpers/assets.dart';
import '../../../../plugins/translator/translator.dart';
import '../../../models/tracker_provider.dart';
import '../myanimelist.dart' as myanimelist;

final Map<int, myanimelist.AnimeListEntity> _cache =
    <int, myanimelist.AnimeListEntity>{};

final TrackerProvider<AnimeProgress> anime = TrackerProvider<AnimeProgress>(
  name: Translator.t.myAnimeList(),
  image: Assets.myAnimeListLogo,
  getComputed: (
    final String title,
    final String plugin, {
    final bool force = false,
  }) async {
    final cache_schema.CacheSchema? cache =
        DataBox.cache.get('myanimelist-anime-$title-$plugin');

    try {
      if (!force && cache != null) {
        final myanimelist.AnimeListEntity mediaList = _cache[cache.value] ??
            await myanimelist.AnimeListEntity.getFromNodeId(
              cache.value as int,
            );

        return ResolvedTrackerItem(
          title: mediaList.title,
          image: mediaList.mainPictureMedium,
          info: mediaList,
        );
      }
    } catch (_) {}

    final List<myanimelist.SearchAnimeEntity> media =
        await myanimelist.searchAnime(title);
    if (media.isNotEmpty) {
      final myanimelist.AnimeListEntity mediaList =
          await myanimelist.AnimeListEntity.getFromNodeId(
        media.first.nodeId,
      );

      await DataBox.cache.put(
        'myanimelist-anime-$title-$plugin',
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
    final List<myanimelist.SearchAnimeEntity> media =
        await myanimelist.searchAnime(title);

    return media
        .map(
          (final myanimelist.SearchAnimeEntity x) => ResolvableTrackerItem(
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
    final myanimelist.AnimeListEntity mediaList =
        await myanimelist.AnimeListEntity.getFromNodeId(
      int.parse(item.id),
    );

    await DataBox.cache.put(
      'myanimelist-anime-$title-$plugin',
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
    final AnimeProgress progress,
  ) async {
    final myanimelist.AnimeListEntity info =
        media.info as myanimelist.AnimeListEntity;
    final myanimelist.AnimeListStatus status =
        progress.episodes >= (info.userStatus?.watched ?? -1) &&
                info.details?.finishedAiring == true
            ? myanimelist.AnimeListStatus.completed
            : myanimelist.AnimeListStatus.watching;

    final int episodes = progress.episodes;

    final bool repeating =
        progress.episodes == 1 && (info.userStatus?.watched ?? -1) > 1;

    int changes = 0;
    final List<List<dynamic>> changables = <List<dynamic>>[
      <dynamic>[info.userStatus?.status, status],
      <dynamic>[info.userStatus?.watched, episodes],
      <dynamic>[info.userStatus?.rewatching, repeating],
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
  isLoggedIn: myanimelist.MyAnimeListManager.auth.isValidToken,
  isEnabled: (final String title, final String plugin) =>
      !DataBox.cache.containsKey('myanimelist-anime-$title-$plugin-disabled'),
  setEnabled:
      (final String title, final String plugin, final bool isEnabled) async {
    isEnabled
        ? await DataBox.cache
            .delete('myanimelist-anime-$title-$plugin-disabled')
        : await DataBox.cache.put(
            'myanimelist-anime-$title-$plugin-disabled',
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
    final myanimelist.AnimeListEntity info =
        item.info as myanimelist.AnimeListEntity;

    return info.getDetailedPage(
      context,
      Navigator.of(context).pop,
    );
  },
  isItemSameKind: (
    final ResolvedTrackerItem current,
    final ResolvedTrackerItem unknown,
  ) {
    if (current.info is myanimelist.AnimeListEntity &&
        unknown.info is myanimelist.AnimeListEntity) {
      final myanimelist.AnimeListEntity a =
          current.info as myanimelist.AnimeListEntity;
      final myanimelist.AnimeListEntity b =
          unknown.info as myanimelist.AnimeListEntity;

      return a.nodeId == b.nodeId;
    }

    return false;
  },
);
