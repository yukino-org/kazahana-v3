import 'package:collection/collection.dart';
import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import './fuzzy_date.dart';
import '../../../../ui/components/trackers/detailed_item.dart';
import '../../../../ui/pages/store_page/trackers_page/anilist_page/edit_modal.dart';
import '../../../utils/utils.dart';
import '../../provider.dart';
import '../anilist.dart';

enum AniListMediaListStatus {
  current,
  planning,
  completed,
  dropped,
  paused,
  repeating,
}

extension AniListMediaListStatusUtils on AniListMediaListStatus {
  String get status => toString().split('.').last.toUpperCase();

  String get pretty => StringUtils.capitalize(status);
}

class AniListMediaList {
  AniListMediaList({
    required final this.userId,
    required final this.status,
    required final this.progress,
    required final this.progressVolumes,
    required final this.repeat,
    required final this.score,
    required final this.startedAt,
    required final this.completedAt,
    required final this.media,
  });

  factory AniListMediaList.fromJson(final Map<dynamic, dynamic> json) =>
      AniListMediaList(
        userId: json['userId'] as int,
        status: AniListMediaListStatus.values.firstWhere(
          (final AniListMediaListStatus x) =>
              x.status == json['status'] as String,
        ),
        progress: json['progress'] as int,
        progressVolumes: json['progressVolumes'] as int?,
        repeat: json['repeat'] as int,
        score: json['score'] as int,
        startedAt: AniListFuzzyDate.toDateTime(
          json['startedAt'] as Map<dynamic, dynamic>,
        ),
        completedAt: AniListFuzzyDate.toDateTime(
          json['completedAt'] as Map<dynamic, dynamic>,
        ),
        media: AniListMedia.fromJson(json['media'] as Map<dynamic, dynamic>),
      );

  factory AniListMediaList.partial({
    required final int userId,
    required final AniListMedia media,
    final AniListMediaListStatus status = AniListMediaListStatus.planning,
    final int progress = 0,
    final int? progressVolumes,
    final int repeat = 0,
    final int? score,
    final DateTime? startedAt,
    final DateTime? completedAt,
  }) =>
      AniListMediaList(
        userId: userId,
        status: status,
        progress: progress,
        progressVolumes: progressVolumes,
        repeat: repeat,
        score: score,
        startedAt: startedAt,
        completedAt: completedAt,
        media: media,
      );

  final int userId;
  AniListMediaListStatus status;
  int progress;
  int? progressVolumes;
  int repeat;
  int? score;
  DateTime? startedAt;
  DateTime? completedAt;
  final AniListMedia media;

  static const String query = '''
{
  userId
  status
  progress
  progressVolumes
  score (format: POINT_100)
  repeat
  startedAt ${AniListFuzzyDate.query}
  completedAt ${AniListFuzzyDate.query}
  media ${AniListMedia.query}
}
    ''';

  Future<void> update({
    required final AniListMediaListStatus? status,
    required final int? progress,
    required final int? progressVolumes,
    required final int? score,
    required final int? repeat,
  }) async {
    const String query = '''
mutation (
  \$mediaId: Int,
  \$status: MediaListStatus,
  \$progress: Int,
  \$progressVolumes: Int,
  \$scoreRaw: Int,
  \$repeat: Int
) {
  SaveMediaListEntry (
    mediaId: \$mediaId,
    status: \$status,
    progress: \$progress,
    progressVolumes: \$progressVolumes,
    scoreRaw: \$scoreRaw,
    repeat: \$repeat
  ) {
    status
    progress
    progressVolumes
    score (format: POINT_100)
    repeat
    startedAt ${AniListFuzzyDate.query}
    completedAt ${AniListFuzzyDate.query}
  }
}
  ''';

    final dynamic res = await AnilistManager.request(
      RequestBody(
        query: query,
        variables: <dynamic, dynamic>{
          'mediaId': media.id,
          'status': status?.status,
          'progress': progress,
          'progressVolumes': progressVolumes,
          'scoreRaw': score,
          'repeat': repeat,
        }..removeWhere(
            (final dynamic key, final dynamic value) => value == null,
          ),
      ),
    );

    final Map<dynamic, dynamic> json =
        res['data']['SaveMediaListEntry'] as Map<dynamic, dynamic>;

    this.status = AniListMediaListStatus.values.firstWhere(
      (final AniListMediaListStatus x) => x.status == json['status'] as String,
    );
    this.progress = json['progress'] as int;
    this.progressVolumes = json['progressVolumes'] as int?;
    this.score = json['score'] as int;
    this.repeat = json['repeat'] as int;

    startedAt =
        AniListFuzzyDate.toDateTime(json['startedAt'] as Map<dynamic, dynamic>);
    completedAt = AniListFuzzyDate.toDateTime(
      json['completedAt'] as Map<dynamic, dynamic>,
    );
  }

  DetailedInfo toDetailedInfo() => DetailedInfo(
        title: media.titleUserPreferred,
        description: media.description,
        type: media.type,
        thumbnail: media.coverImageExtraLarge,
        banner: media.bannerImage,
        status: status.pretty,
        progress: Progress(
          progress: progress,
          total: media.episodes ?? media.chapters,
          startedAt: startedAt,
          completedAt: completedAt,
          volumes: media.type == ExtensionType.manga
              ? VolumesProgress(
                  progress: progressVolumes,
                  total: media.volumes,
                )
              : null,
        ),
        score: score,
        repeated: repeat,
        characters: media.characters
            .map((final AniListCharacter x) => x.toCharacter())
            .toList(),
      );

  Widget getDetailedPage(
    final BuildContext context, [
    final void Function()? onPlay,
  ]) =>
      DetailedItem(
        item: toDetailedInfo(),
        onPlay: onPlay,
        onEdit: (final OnEditCallback cb) => EditModal(
          media: this,
          callback: cb,
        ),
      );

  static Future<AniListMediaList> getFromMediaId(
    final int id,
    final int userId,
  ) async {
    final AniListMediaList? mediaList = await tryGetFromMediaId(id, userId);
    if (mediaList != null) {
      return mediaList;
    }

    final AniListMedia media = await AniListMedia.getMediaFromId(id);
    return AniListMediaList.partial(userId: userId, media: media);
  }

  static Future<AniListMediaList?> tryGetFromMediaId(
    final int id,
    final int userId,
  ) async {
    const String query = '''
query (
  \$mediaId: Int,
  \$userId: Int
) {
  MediaList(
    mediaId: \$mediaId,
    userId: \$userId
  ) ${AniListMediaList.query}
}
    ''';

    final dynamic res = await AnilistManager.request(
      RequestBody(
        query: query,
        variables: <dynamic, dynamic>{
          'mediaId': id,
          'userId': userId,
        },
      ),
    );

    return res['errors'] is List<dynamic> &&
            (res['errors'] as List<dynamic>).firstWhereOrNull(
                  (final dynamic x) => x['status'] == 404,
                ) !=
                null &&
            res['data']['MediaList'] == null
        ? null
        : AniListMediaList.fromJson(
            res['data']['MediaList'] as Map<dynamic, dynamic>,
          );
  }
}

const int _perPage = 50;

Future<List<AniListMediaList>> getMediaList(
  final ExtensionType type,
  final AniListMediaListStatus status,
  final int page,
) async {
  const String query = '''
query (
    \$userId: Int,
    \$type: MediaType,
    \$status: [MediaListStatus],
    \$page: Int,
    \$perpage: Int
) {
  Page (page: \$page, perPage: \$perpage) {
    mediaList (userId: \$userId, type: \$type, status_in: \$status) ${AniListMediaList.query}
  }
}
  ''';

  final AniListUserInfo user = await AniListUserInfo.getUserInfo();

  final dynamic res = await AnilistManager.request(
    RequestBody(
      query: query,
      variables: <dynamic, dynamic>{
        'userId': user.id,
        'type': type.type.toUpperCase(),
        'status': status.status,
        'page': page,
        'perpage': _perPage,
      },
    ),
  );

  return (res['data']['Page']['mediaList'] as List<dynamic>)
      .cast<Map<dynamic, dynamic>>()
      .map((final Map<dynamic, dynamic> x) => AniListMediaList.fromJson(x))
      .toList();
}
