import './_fuzzy_date.dart';
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

  static Future<MediaList> getFromMediaId(final int id) async {
    const String query = '''
query (
  \$mediaId: Int
) {
  MediaList(mediaId: \$mediaId) ${MediaList.query}
}
    ''';

    final dynamic res = await AnilistManager.request(
      RequestBody(
        query: query,
        variables: <dynamic, dynamic>{
          'mediaId': id,
        },
      ),
    );

    return MediaList.fromJson(
      res['data']['MediaList'] as Map<dynamic, dynamic>,
    );
  }
}

const int _perPage = 50;

Future<List<MediaList>> getMediaList(
  final MediaType type,
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
        'type': type.type,
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
