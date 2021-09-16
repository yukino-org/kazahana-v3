import '../../plugins/helpers/utils/string.dart';

enum EntityTypes {
  anime,
  manga,
  ova,
  ona,
  lightNovel,
}

extension EntityTypesEntity on EntityTypes {
  String get type => StringUtils.capitalize(
        toString().split('.').last.replaceAllMapped(
              RegExp('[A-Z]'),
              (final Match match) => ' ${match.group(0)}',
            ),
      );
}

class Entity {
  Entity({
    required final this.title,
    required final this.url,
    required final this.thumbnail,
    required final this.type,
    required final this.latest,
    required final this.score,
    final this.tags = const <String>[],
    final this.description,
    final this.time,
  });

  final String title;
  final String url;
  final String thumbnail;
  final EntityTypes type;
  final String? latest;
  final int? score;
  final List<String> tags;
  final String? description;
  final String? time;
}
