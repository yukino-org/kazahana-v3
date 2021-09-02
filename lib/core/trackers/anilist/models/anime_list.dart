import './media.dart';

class AnimeList {
  AnimeList({
    required final this.userId,
    required final this.status,
    required final this.progress,
    required final this.startedAt,
    required final this.completedAt,
    required final this.media,
  });

  factory AnimeList.fromJson(final Map<dynamic, dynamic> json) => AnimeList(
        userId: json['userId'] as int,
        status: json['status'] as String,
        progress: json['progress'] as int,
        startedAt: json['startedAt'] as DateTime,
        completedAt: json['completedAt'] as DateTime,
        media: Media.fromJson(json['media'] as Map<dynamic, dynamic>),
      );

  final int userId;
  final String status;
  final int progress;
  final DateTime startedAt;
  final DateTime completedAt;
  final Media media;
}
