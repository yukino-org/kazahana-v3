import 'package:utilx/utilx.dart';

class AnilistUserStatistics {
  const AnilistUserStatistics(this.json);

  final JsonMap json;

  int get count => json['count'] as int;
  double get meanScore => (json['meanScore'] as num).toDouble();
  double get standardDeviation => (json['standardDeviation'] as num).toDouble();
  int? get minutesWatched => json['minutesWatched'] as int?;
  int? get episodesWatched => json['episodesWatched'] as int?;
  int? get chaptersRead => json['chaptersRead'] as int?;
  int? get volumesRead => json['volumesRead'] as int?;
}

class AnilistUser {
  const AnilistUser(this.json);

  final JsonMap json;

  int get id => json['id'] as int;
  String get name => json['name'] as String;
  String? get about => json['about'] as String?;
  JsonMap get avatar => json['avatar'] as JsonMap;
  String? get avatarLarge => avatar['large'] as String?;
  String? get avatarMedium => avatar['medium'] as String?;
  String? get bannerImage => json['bannerImage'] as String?;
  String get siteUrl => json['siteUrl'] as String;
  JsonMap? get statistics => json['statistics'] as JsonMap?;
  AnilistUserStatistics? get animeStatistics => statistics?['anime'] != null
      ? AnilistUserStatistics(statistics!['anime'] as JsonMap)
      : null;
  AnilistUserStatistics? get mangaStatistics => statistics?['manga'] != null
      ? AnilistUserStatistics(statistics!['manga'] as JsonMap)
      : null;

  static const String query = '''
{
  id
  name
  about(asHtml: true)
  avatar {
    large
    medium
  }
  bannerImage
  siteUrl
  statistics {
    anime {
      count
      meanScore
      standardDeviation
      minutesWatched
      episodesWatched
      chaptersRead
      volumesRead
    }
    manga {
      count
      meanScore
      standardDeviation
      minutesWatched
      episodesWatched
      chaptersRead
      volumesRead
    }
  }
}
''';
}
