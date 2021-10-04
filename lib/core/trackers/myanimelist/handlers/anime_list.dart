import 'dart:convert';
import '../../../../plugins/helpers/utils/string.dart';
import '../myanimelist.dart';

enum AnimeListStatus {
  watching,
  completed,
  onHold,
  dropped,
  planToWatch,
}

extension AnimeListStatusUtils on AnimeListStatus {
  String get status =>
      StringUtils.pascalToSnakeCase(toString().split('.').last);

  String get pretty => StringUtils.pascalPretty(toString().split('.').last);
}

class AnimeListEntityProgress {
  AnimeListEntityProgress({
    required final this.status,
    required final this.score,
    required final this.watched,
    required final this.rewatching,
    required final this.updatedAt,
  });

  factory AnimeListEntityProgress.fromJson(final Map<dynamic, dynamic> json) =>
      AnimeListEntityProgress(
        status: AnimeListStatus.values.firstWhere(
          (final AnimeListStatus x) => x.status == (json['status'] as String),
        ),
        score: json['score'] as int,
        watched: json['num_episodes_watched'] as int,
        rewatching: json['is_rewatching'] as bool,
        updatedAt: json['updated_at'] as String,
      );

  final AnimeListStatus status;
  final int score;
  final int watched;
  final bool rewatching;
  final String updatedAt;
}

class AnimeListEntity {
  AnimeListEntity({
    required final this.nodeId,
    required final this.title,
    required final this.mainPictureMedium,
    required final this.mainPictureLarge,
    required final this.status,
  });

  factory AnimeListEntity.fromJson(final Map<dynamic, dynamic> json) =>
      AnimeListEntity(
        nodeId: json['node']['id'] as int,
        title: json['node']['title'] as String,
        mainPictureMedium: json['node']['main_picture']['medium'] as String,
        mainPictureLarge: json['node']['main_picture']['large'] as String,
        status: AnimeListEntityProgress.fromJson(
          json['list_status'] as Map<dynamic, dynamic>,
        ),
      );

  final int nodeId;
  final String title;
  final String mainPictureMedium;
  final String mainPictureLarge;
  AnimeListEntityProgress status;

  Future<AnimeListEntity> update({
    final AnimeListStatus? status,
    final int? score,
    final int? watched,
    final bool? rewatching,
  }) async {
    final String res = await MyAnimeListManager.request(
        MyAnimeListRequestMethods.put,
        '/anime/$nodeId/my_list_status', <String, dynamic>{
      'status': status?.status,
      'is_rewatching': rewatching,
      'score': score,
      'num_watched_episodes': watched,
    });

    this.status = AnimeListEntityProgress.fromJson(
      json.decode(res) as Map<dynamic, dynamic>,
    );

    return this;
  }
}

Future<List<AnimeListEntity>> getAnimeList(
  final AnimeListStatus status,
  final int page, [
  final int perPage = 100,
]) async {
  final String res = await MyAnimeListManager.request(
    MyAnimeListRequestMethods.get,
    '/users/@me/animelist?fields=list_status&sort=list_updated_at&limit=$perPage&offset=${perPage * page}&status=${status.status}',
  );

  return ((json.decode(res) as Map<dynamic, dynamic>)['data'] as List<dynamic>)
      .cast<Map<dynamic, dynamic>>()
      .map((final Map<dynamic, dynamic> x) => AnimeListEntity.fromJson(x))
      .toList();
}
