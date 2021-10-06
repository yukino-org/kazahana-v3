import 'package:extensions/extensions.dart' as extensions;

class VolumesProgress {
  VolumesProgress({
    required final this.progress,
    required final this.total,
  });

  final int? progress;
  final int? total;
}

class Progress {
  Progress({
    required final this.progress,
    required final this.total,
    required final this.startedAt,
    required final this.completedAt,
    required final this.volumes,
  });

  final int progress;
  final int? total;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final VolumesProgress? volumes;
}

class Character {
  Character({
    required final this.name,
    required final this.role,
    required final this.image,
  });

  final String name;
  final String role;
  final String image;
}

class DetailedInfo {
  DetailedInfo({
    required final this.title,
    required final this.description,
    required final this.type,
    required final this.thumbnail,
    required final this.banner,
    required final this.status,
    required final this.progress,
    required final this.score,
    required final this.repeated,
    required final this.characters,
  });

  final String title;
  final String? description;
  final extensions.ExtensionType type;
  final String thumbnail;
  final String? banner;
  final String? status;
  final Progress progress;
  final int? score;
  final int? repeated;
  final List<Character> characters;
}
