import 'package:utilx/utils.dart';
import '../../utils/exports.dart';
import 'age_rating.dart';
import 'manga_sub_type.dart';
import 'status.dart';

class KitsuManga {
  const KitsuManga._(this.json);

  factory KitsuManga.fromJson(final JsonMap json) => KitsuManga._(json);

  final JsonMap json;

  String get id => json['id'] as String;
  String get type => json['type'] as String;
  String get url => (json['links'] as JsonMap)['self'] as String;
  JsonMap get attributes => json['attributes'] as JsonMap;
  String get slug => attributes['slug'] as String;
  String get synopsis => attributes['synopsis'] as String;
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
  int get popularityRank => attributes['popularityRank'] as int;
  int? get ratingRank => attributes['ratingRank'] as int?;
  KitsuAgeRating? get ageRating => attributes['ageRating'] != null
      ? parseKitsuAgeRating(attributes['ageRating'] as String)
      : null;
  String? get ageRatingGuide => attributes['ageRatingGuide'] != null
      ? StringUtils.onlyIfNotEmpty(attributes['ageRatingGuide'] as String)
      : null;
  KitsuMangaSubType get subtype =>
      parseKitsuMangaSubType(attributes['subtype'] as String);
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
  int? get chapterCount => attributes['chapterCount'] as int?;
  int? get volumeCount => attributes['volumeCount'] as int?;
  String? get serialization => attributes['serialization'] != null
      ? StringUtils.onlyIfNotEmpty(attributes['serialization'] as String)
      : null;
}
