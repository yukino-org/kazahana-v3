import 'package:utilx/utils.dart';
import '../../utils/exports.dart';
import 'age_rating.dart';
import 'anime_sub_type.dart';
import 'status.dart';

class KitsuAnime {
  const KitsuAnime._(this.json);

  factory KitsuAnime.fromJson(final JsonMap json) => KitsuAnime._(json);

  final JsonMap json;

  String get id => json['id'] as String;
  String get type => json['type'] as String;
  String get url => (json['links'] as JsonMap)['self'] as String;
  JsonMap get attributes => json['attributes'] as JsonMap;
  String get slug => attributes['slug'] as String;
  String? get synopsis => attributes['synopsis'] as String?;
  Map<String, String?> get titles =>
      castJsonMap<String, String?>(attributes['titles']);
  String get canonicalTitle => attributes['canonicalTitle'] as String;
  List<String> get abbreviatedTitles =>
      castList<String>(attributes['abbreviatedTitles']);
  String? get averageRating => attributes['averageRating'] as String?;
  String? get startDateRaw => attributes['startDate'] as String?;
  DateTime? get startDate =>
      startDateRaw != null ? DateTime.parse(startDateRaw!) : null;
  String? get endDateRaw => attributes['endDate'] as String?;
  DateTime? get endDate =>
      endDateRaw != null ? DateTime.parse(endDateRaw!) : null;
  int? get popularityRank => attributes['popularityRank'] as int?;
  int? get ratingRank => attributes['ratingRank'] as int?;
  KitsuAgeRating? get ageRating => attributes['ageRating'] != null
      ? parseKitsuAgeRating(attributes['ageRating'] as String)
      : null;
  String? get ageRatingGuide => attributes['ageRatingGuide'] != null
      ? StringUtils.onlyIfNotEmpty(attributes['ageRatingGuide'] as String)
      : null;
  KitsuAnimeSubType get subtype =>
      parseKitsuAnimeSubType(attributes['subtype'] as String);
  KitsuStatus get status => parseKitsuStatus(attributes['status'] as String);
  String get tba => attributes['tba'] as String;
  Map<String, String> get posterImage =>
      castJsonMap<String, String>(attributes['posterImage']);
  String get posterImageTiny => posterImage['tiny']!;
  String get posterImageSmall => posterImage['small']!;
  String get posterImageMedium => posterImage['medium']!;
  String get posterImageLarge => posterImage['large']!;
  String get posterImageOriginal => posterImage['original']!;
  Map<String, String>? get coverImage => attributes['coverImage'] != null
      ? castJsonMap<String, String>(attributes['coverImage'])
      : null;
  String? get coverImageTiny => coverImage?['tiny']!;
  String? get coverImageSmall => coverImage?['small']!;
  String? get coverImageLarge => coverImage?['large']!;
  String? get coverImageOriginal => coverImage?['original']!;
  int? get episodeCount => attributes['episodeCount'] as int?;
  int? get episodeLength => attributes['episodeLength'] as int?;
  bool get nsfw => attributes['nsfw'] as bool;
}
