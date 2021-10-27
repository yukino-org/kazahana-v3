import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import '../../../database/database.dart';
import '../../../database/schemas/cache/cache.dart' as cache_schema;
import '../../../helpers/assets.dart';
import '../../../translator/translator.dart';
import '../../provider.dart';
import '../anilist.dart';

abstract class AniListProvider {
  static final TrackerProvider<AnimeProgress> anime =
      TrackerProvider<AnimeProgress>(
    name: Translator.t.anilist(),
    image: Assets.anilistLogo,
    getComputed: _getComputed(ExtensionType.anime),
    getComputables: _getComputables(ExtensionType.anime),
    resolveComputed: _resolveComputable(ExtensionType.anime),
    updateComputed: (
      final ResolvedTrackerItem media,
      final AnimeProgress progress,
    ) async {
      final AniListMediaList info = media.info as AniListMediaList;
      final AniListMediaListStatus status = media.info.media.episodes != null &&
              progress.episodes >= info.media.episodes!
          ? AniListMediaListStatus.completed
          : AniListMediaListStatus.current;

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
    isLoggedIn: _isLoggedIn,
    isEnabled: _isEnabled(ExtensionType.anime),
    setEnabled: _setEnabled(ExtensionType.anime),
    getDetailedPage: _getDetailedPage,
    isItemSameKind: _isItemSameKind,
  );

  static final TrackerProvider<MangaProgress> manga =
      TrackerProvider<MangaProgress>(
    name: Translator.t.anilist(),
    image: Assets.anilistLogo,
    getComputed: _getComputed(ExtensionType.manga),
    getComputables: _getComputables(ExtensionType.manga),
    resolveComputed: _resolveComputable(ExtensionType.manga),
    updateComputed: (
      final ResolvedTrackerItem media,
      final MangaProgress progress,
    ) async {
      final AniListMediaList info = media.info as AniListMediaList;
      final AniListMediaListStatus status = media.info.media.chapters != null &&
              progress.chapters >= info.media.chapters!
          ? AniListMediaListStatus.completed
          : AniListMediaListStatus.current;

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
    isLoggedIn: _isLoggedIn,
    isEnabled: _isEnabled(ExtensionType.manga),
    setEnabled: _setEnabled(ExtensionType.manga),
    getDetailedPage: _getDetailedPage,
    isItemSameKind: _isItemSameKind,
  );

  static final Map<int, AniListMediaList> _cache = <int, AniListMediaList>{};

  static final bool Function() _isLoggedIn = AnilistManager.auth.isValidToken;

  static Future<ResolvedTrackerItem?> Function(
    String title,
    String plugin, {
    bool force,
  }) _getComputed(
    final ExtensionType mediaType,
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
            final AniListUserInfo user = await AniListUserInfo.getUserInfo();

            final AniListMediaList mediaList = _cache[cache.value] ??
                await AniListMediaList.getFromMediaId(
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

        final List<AniListMedia> media =
            await AniListMedia.search(title, mediaType, 0, 1);
        if (media.isNotEmpty) {
          final AniListUserInfo user = await AniListUserInfo.getUserInfo();

          final AniListMediaList mediaList =
              await AniListMediaList.getFromMediaId(media.first.id, user.id);

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

  static Future<List<ResolvableTrackerItem>> Function(String title)
      _getComputables(
    final ExtensionType mediaType,
  ) =>
          (final String title) async {
            final List<AniListMedia> media =
                await AniListMedia.search(title, mediaType);
            return media
                .map(
                  (final AniListMedia x) => ResolvableTrackerItem(
                    id: x.id.toString(),
                    title: x.titleUserPreferred,
                    image: x.coverImageMedium,
                  ),
                )
                .toList();
          };

  static Future<ResolvedTrackerItem> Function(
    String title,
    String plugin,
    ResolvableTrackerItem item,
  ) _resolveComputable(
    final ExtensionType mediaType,
  ) =>
      (
        final String title,
        final String plugin,
        final ResolvableTrackerItem item,
      ) async {
        final AniListUserInfo user = await AniListUserInfo.getUserInfo();

        final AniListMediaList mediaList =
            await AniListMediaList.getFromMediaId(int.parse(item.id), user.id);

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

  static bool Function(String, String) _isEnabled(
    final ExtensionType mediaType,
  ) =>
      (final String title, final String plugin) => !DataBox.cache
          .containsKey('anilist-${mediaType.type}-$title-$plugin-disabled');

  static Future<void> Function(String, String, bool) _setEnabled(
    final ExtensionType mediaType,
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

  static Widget _getDetailedPage(
    final BuildContext context,
    final ResolvedTrackerItem item,
  ) =>
      (item.info as AniListMediaList).getDetailedPage(
        context,
        Navigator.of(context).pop,
      );

  static bool _isItemSameKind(
    final ResolvedTrackerItem current,
    final ResolvedTrackerItem unknown,
  ) =>
      unknown.info is AniListMediaList &&
      unknown.info.media.id == current.info.media.id;
}
