import 'package:extensions/extensions.dart' as extensions;
import 'package:flutter/material.dart';
import './anilist.dart' as anilist;
import '../../../plugins/database/database.dart' show DataBox;
import '../../../plugins/database/schemas/cache/cache.dart' as cache_schema;
import '../../../plugins/helpers/assets.dart';
import '../../../plugins/translator/translator.dart';
import '../../models/tracker_provider.dart';

final Map<int, anilist.MediaList> _cache = <int, anilist.MediaList>{};

Future<ResolvedTrackerItem?> Function(
  String title,
  String plugin, {
  bool force,
}) getComputed(
  final extensions.ExtensionType mediaType,
) =>
    (
      final String title,
      final String plugin, {
      final bool force = false,
    }) async {
      final cache_schema.CacheSchema? cache =
          DataBox.cache.get('anilist-$title-$plugin');

      try {
        if (!force && cache != null) {
          final anilist.UserInfo user = await anilist.getUserInfo();

          final anilist.MediaList mediaList = _cache[cache.value] ??
              await anilist.MediaList.getFromMediaId(
                cache.value as int,
                user.id,
              );

          return ResolvedTrackerItem(
            title: mediaList.media.titleUserPreferred,
            image: mediaList.media.coverImageMedium,
            info: mediaList,
          );
        }
      } catch (_) {}

      final List<anilist.Media> media =
          await anilist.Media.search(title, mediaType, 0, 1);
      if (media.isNotEmpty) {
        final anilist.UserInfo user = await anilist.getUserInfo();

        final anilist.MediaList mediaList =
            await anilist.MediaList.getFromMediaId(media.first.id, user.id);

        await DataBox.cache.put(
          'anilist-$title-$plugin',
          cache_schema.CacheSchema(
            media.first.id,
            0,
          ),
        );

        return ResolvedTrackerItem(
          title: mediaList.media.titleUserPreferred,
          image: mediaList.media.coverImageMedium,
          info: mediaList,
        );
      }
    };

Future<List<ResolvableTrackerItem>> Function(String title) getComputables(
  final extensions.ExtensionType mediaType,
) =>
    (final String title) async {
      final List<anilist.Media> media =
          await anilist.Media.search(title, mediaType);
      return media
          .map(
            (final anilist.Media x) => ResolvableTrackerItem(
              id: x.id.toString(),
              title: x.titleUserPreferred,
              image: x.coverImageMedium,
            ),
          )
          .toList();
    };

Future<ResolvedTrackerItem> Function(
  String title,
  String plugin,
  ResolvableTrackerItem item,
) resolveComputable(
  final extensions.ExtensionType mediaType,
) =>
    (
      final String title,
      final String plugin,
      final ResolvableTrackerItem item,
    ) async {
      final anilist.UserInfo user = await anilist.getUserInfo();

      final anilist.MediaList mediaList =
          await anilist.MediaList.getFromMediaId(int.parse(item.id), user.id);

      await DataBox.cache.put(
        'anilist-$title-$plugin',
        cache_schema.CacheSchema(
          mediaList.media.id,
          0,
        ),
      );

      _cache[mediaList.media.id] = mediaList;

      return ResolvedTrackerItem(
        title: mediaList.media.titleUserPreferred,
        image: mediaList.media.coverImageMedium,
        info: mediaList,
      );
    };

final bool Function() isLoggedIn = anilist.AnilistManager.auth.isValidToken;

bool Function(String, String) isEnabled(
  final extensions.ExtensionType mediaType,
) =>
    (final String title, final String plugin) => !DataBox.cache
        .containsKey('anilist-${mediaType.type}-$title-$plugin-disabled');

Future<void> Function(String, String, bool) setEnabled(
  final extensions.ExtensionType mediaType,
) =>

    // ignore: avoid_positional_boolean_parameters
    (final String title, final String plugin, final bool isEnabled) async {
      isEnabled
          ? await DataBox.cache
              .delete('anilist-${mediaType.type}-$title-$plugin-disabled')
          : await DataBox.cache.put(
              'anilist-${mediaType.type}-$title-$plugin-disabled',
              cache_schema.CacheSchema(
                null,
                0,
              ),
            );
    };

Widget getDetailedPage(
  final BuildContext context,
  final ResolvedTrackerItem item,
) =>
    (item.info as anilist.MediaList).getDetailedPage(
      context,
      Navigator.of(context).pop,
    );

bool isItemSameKind(
  final ResolvedTrackerItem current,
  final ResolvedTrackerItem unknown,
) =>
    unknown.info is anilist.MediaList &&
    unknown.info.media.id == current.info.media.id;

final TrackerProvider<AnimeProgress> anime = TrackerProvider<AnimeProgress>(
  name: Translator.t.anilist(),
  image: Assets.anilistLogo,
  getComputed: getComputed(extensions.ExtensionType.anime),
  getComputables: getComputables(extensions.ExtensionType.anime),
  resolveComputed: resolveComputable(extensions.ExtensionType.anime),
  updateComputed: (
    final ResolvedTrackerItem media,
    final AnimeProgress progress,
  ) async {
    final anilist.MediaList info = media.info as anilist.MediaList;
    final anilist.MediaListStatus status = media.info.media.episodes != null &&
            progress.episodes >= info.media.episodes!
        ? anilist.MediaListStatus.completed
        : anilist.MediaListStatus.current;

    final int episodes = progress.episodes;

    final int repeat = progress.episodes == 1 && info.progress > 1
        ? info.repeat + 1
        : info.repeat;

    int changes = 0;
    final List<List<dynamic>> changables = <List<dynamic>>[
      <dynamic>[media.info.status, status],
      <dynamic>[media.info.progress, episodes],
      <dynamic>[media.info.repeat, repeat],
    ];

    for (final List<dynamic> item in changables) {
      if (item.first != item.last) {
        changes += 1;
      }
    }

    if (changes > 0) {
      await media.info.update(
        status: status,
        progress: episodes,
        progressVolumes: null,
        score: null,
        repeat: repeat,
      );

      _cache[info.media.id] = info;
      onItemUpdateChangeNotifier.dispatch(media);
    }
  },
  isLoggedIn: isLoggedIn,
  isEnabled: isEnabled(extensions.ExtensionType.anime),
  setEnabled: setEnabled(extensions.ExtensionType.anime),
  getDetailedPage: getDetailedPage,
  isItemSameKind: isItemSameKind,
);

final TrackerProvider<MangaProgress> manga = TrackerProvider<MangaProgress>(
  name: Translator.t.anilist(),
  image: Assets.anilistLogo,
  getComputed: getComputed(extensions.ExtensionType.manga),
  getComputables: getComputables(extensions.ExtensionType.manga),
  resolveComputed: resolveComputable(extensions.ExtensionType.manga),
  updateComputed: (
    final ResolvedTrackerItem media,
    final MangaProgress progress,
  ) async {
    final anilist.MediaList info = media.info as anilist.MediaList;
    final anilist.MediaListStatus status = media.info.media.chapters != null &&
            progress.chapters >= info.media.chapters!
        ? anilist.MediaListStatus.completed
        : anilist.MediaListStatus.current;

    final int chapters = progress.chapters;
    final int? volumes = progress.volume ?? info.progressVolumes;

    final int repeat = progress.chapters == 1 && info.progress > 1
        ? info.repeat + 1
        : info.repeat;

    int changes = 0;
    final List<List<dynamic>> changables = <List<dynamic>>[
      <dynamic>[media.info.status, status],
      <dynamic>[media.info.progress, chapters],
      <dynamic>[media.info.progressVolumes, volumes],
      <dynamic>[media.info.repeat, repeat],
    ];

    for (final List<dynamic> item in changables) {
      if (item.first != item.last) {
        changes += 1;
      }
    }

    if (changes > 0) {
      await media.info.update(
        status: status,
        progress: chapters,
        progressVolumes: volumes,
        score: null,
        repeat: repeat,
      );

      _cache[info.media.id] = info;
      onItemUpdateChangeNotifier.dispatch(media);
    }
  },
  isLoggedIn: isLoggedIn,
  isEnabled: isEnabled(extensions.ExtensionType.manga),
  setEnabled: setEnabled(extensions.ExtensionType.manga),
  getDetailedPage: getDetailedPage,
  isItemSameKind: isItemSameKind,
);
