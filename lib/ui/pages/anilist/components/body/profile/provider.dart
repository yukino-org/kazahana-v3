import 'dart:async';
import '../../../../../../core/exports.dart';
import '../../../provider.dart';

class AnilistProfileCategory {
  const AnilistProfileCategory(this.type, this.status);

  factory AnilistProfileCategory.parse(final String value) {
    final List<String> split = value.split('_');
    return AnilistProfileCategory(
      parseAnilistMediaType(split.first),
      parseAnilistMediaListStatus(split.last),
    );
  }

  final AnilistMediaType type;
  final AnilistMediaListStatus status;

  AnilistProfileCategory copyWith({
    final AnilistMediaType? type,
    final AnilistMediaListStatus? status,
  }) =>
      AnilistProfileCategory(type ?? this.type, status ?? this.status);

  String get stringify => '${type.stringify}_${status.stringify}';

  @override
  bool operator ==(final Object other) =>
      other is AnilistProfileCategory &&
      type == other.type &&
      status == other.status;

  @override
  int get hashCode => Object.hash(type, status);
}

class AnilistPageProfileProvider extends StatedChangeNotifier {
  AnilistPageProfileProvider(this.pageProvider);

  final AnilistPageProvider pageProvider;

  AnilistProfileCategory category = const AnilistProfileCategory(
    AnilistMediaType.anime,
    AnilistMediaListStatus.current,
  );
  final StatedValue<TwinTuple<AnilistProfileCategory, List<AnilistMedia>>>
      list =
      StatedValue<TwinTuple<AnilistProfileCategory, List<AnilistMedia>>>();

  Future<void> initialize() async {
    final AnilistProfileCategory? lastVisitedCategory =
        await getAnilistLastVisitedCategory();
    if (lastVisitedCategory != null && lastVisitedCategory != category) {
      category = lastVisitedCategory;
      notifyListeners();
    }

    fetch();
  }

  Future<void> change(final AnilistProfileCategory nCategory) async {
    if (category == nCategory) return;
    category = nCategory;
    await setAnilistLastVisitedCategory(category);
    await fetch();
  }

  Future<void> fetch() async {
    if (list.hasFinished && list.value.first == category) return;
    list.waiting();
    notifyListeners();

    try {
      list.finish(
        TwinTuple<AnilistProfileCategory, List<AnilistMedia>>(
          category,
          await AnilistMediaListEndpoints.fetch(
            userId: pageProvider.user!.id,
            type: category.type,
            status: category.status,
            sort: AnilistMediaListSort.addedTimeDesc,
          ),
        ),
      );
    } catch (error, stackTrace) {
      list.fail(error, stackTrace);
    }
    notifyListeners();
  }

  static const String kAnilistLastVisitedCategoryKey =
      'anilist_last_visited_list';

  static Future<AnilistProfileCategory?> getAnilistLastVisitedCategory() async {
    final String? value =
        await CacheDatabase.get<String?>(kAnilistLastVisitedCategoryKey);
    return value != null ? AnilistProfileCategory.parse(value) : null;
  }

  static Future<void> setAnilistLastVisitedCategory(
    final AnilistProfileCategory category,
  ) async {
    await CacheDatabase.set(kAnilistLastVisitedCategoryKey, category.stringify);
  }
}
