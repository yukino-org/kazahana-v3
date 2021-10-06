import 'package:collection/collection.dart';
import 'package:extensions/extensions.dart' as extensions;
import 'package:flutter/cupertino.dart';
import './_fuzzy_date.dart';
import '../../../../components/trackers/detailed_item.dart';
import '../../../../pages/store_page/trackers_page/anilist_page/edit_modal.dart';
import '../../../../plugins/helpers/utils/string.dart';
import '../../detailed_info.dart' as detailed_info;
import '../anilist.dart';

enum MediaListStatus {
  current,
  planning,
  completed,
  dropped,
  paused,
  repeating,
}

extension MediaListStatusUtils on MediaListStatus {
  String get status => toString().split('.').last.toUpperCase();

  String get pretty => StringUtils.capitalize(status);
}

class MediaList {
  MediaList({
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

  factory MediaList.fromJson(final Map<dynamic, dynamic> json) => MediaList(
        userId: json['userId'] as int,
        status: MediaListStatus.values.firstWhere(
          (final MediaListStatus x) => x.status == json['status'] as String,
        ),
        progress: json['progress'] as int,
        progressVolumes: json['progressVolumes'] as int?,
        repeat: json['repeat'] as int,
        score: json['score'] as int,
        startedAt:
            FuzzyDate.toDateTime(json['startedAt'] as Map<dynamic, dynamic>),
        completedAt:
            FuzzyDate.toDateTime(json['completedAt'] as Map<dynamic, dynamic>),
        media: Media.fromJson(json['media'] as Map<dynamic, dynamic>),
      );

  factory MediaList.partial({
    required final int userId,
    required final Media media,
    final MediaListStatus status = MediaListStatus.planning,
    final int progress = 0,
    final int? progressVolumes,
    final int repeat = 0,
    final int? score,
    final DateTime? startedAt,
    final DateTime? completedAt,
  }) =>
      MediaList(
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
  MediaListStatus status;
  int progress;
  int? progressVolumes;
  int repeat;
  int? score;
  DateTime? startedAt;
  DateTime? completedAt;
  final Media media;

  static const String query = '''
{
  userId
  status
  progress
  progressVolumes
  score (format: POINT_100)
  repeat
  startedAt ${FuzzyDate.query}
  completedAt ${FuzzyDate.query}
  media ${Media.query}
}
    ''';

  Future<void> update({
    required final MediaListStatus? status,
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
    startedAt ${FuzzyDate.query}
    completedAt ${FuzzyDate.query}
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

    this.status = MediaListStatus.values.firstWhere(
      (final MediaListStatus x) => x.status == json['status'] as String,
    );
    this.progress = json['progress'] as int;
    this.progressVolumes = json['progressVolumes'] as int?;
    this.score = json['score'] as int;
    this.repeat = json['repeat'] as int;

    startedAt =
        FuzzyDate.toDateTime(json['startedAt'] as Map<dynamic, dynamic>);
    completedAt =
        FuzzyDate.toDateTime(json['completedAt'] as Map<dynamic, dynamic>);
  }

  detailed_info.DetailedInfo toDetailedInfo() => detailed_info.DetailedInfo(
        title: media.titleUserPreferred,
        description: media.description,
        type: media.type,
        thumbnail: media.coverImageExtraLarge,
        banner: media.bannerImage,
        status: status.pretty,
        progress: detailed_info.Progress(
          progress: progress,
          total: media.episodes ?? media.chapters,
          startedAt: startedAt,
          completedAt: completedAt,
          volumes: media.type == extensions.ExtensionType.manga
              ? detailed_info.VolumesProgress(
                  progress: progressVolumes,
                  total: media.volumes,
                )
              : null,
        ),
        score: score,
        repeated: repeat,
        characters: media.characters
            .map((final Character x) => x.toCharacter())
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

  static Future<MediaList> getFromMediaId(
    final int id,
    final int userId,
  ) async =>
      (await tryGetFromMediaId(id, userId))!;

  static Future<MediaList?> tryGetFromMediaId(
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
  ) ${MediaList.query}
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
        : MediaList.fromJson(
            res['data']['MediaList'] as Map<dynamic, dynamic>,
          );
  }
}

const int _perPage = 50;

Future<List<MediaList>> getMediaList(
  final extensions.ExtensionType type,
  final MediaListStatus status,
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
    mediaList (userId: \$userId, type: \$type, status_in: \$status) ${MediaList.query}
  }
}
  ''';

  final UserInfo user = await getUserInfo();

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
      .map((final Map<dynamic, dynamic> x) => MediaList.fromJson(x))
      .toList();
}
