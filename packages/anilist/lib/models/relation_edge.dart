import 'package:utilx/utilx.dart';
import 'media.dart';
import 'relation_type.dart';

class AnilistRelationEdge {
  const AnilistRelationEdge(this.json);

  final JsonMap json;

  int get id => json['id'] as int;
  AnilistRelationType get relationType =>
      parseAnilistRelationType(json['relationType'] as String);
  AnilistMedia get node => AnilistMedia(json['node'] as JsonMap);

  static const String query = '''
relations {
  edges {
    id
    relationType
    node ${AnilistMedia.query}
  }
}
  ''';
}
