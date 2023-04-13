import 'package:kazahana/core/exports.dart';

class ViewPageContentProvider extends StatedChangeNotifier {
  ViewPageContentProvider(this.media);

  final AnilistMedia media;

  TenkaMetadata? metadata;
  dynamic extractor;

  final StatedValue<TwinTuple<SearchInfo, AnimeInfo>?> computed =
      StatedValue<TwinTuple<SearchInfo, AnimeInfo>?>();
  final StatedValue<List<SearchInfo>> searches =
      StatedValue<List<SearchInfo>>();

//Initialize will be called at some point either during app startup or after the user selects a provider from the episodes tab.

  Future<void> initialize() async {
    final String? lastUsedExtractorId = await getLastUsedExtractor(type);
    final TenkaMetadata? lastUsedExtractor =
        TenkaManager.repository.installed[lastUsedExtractorId];
    if (lastUsedExtractor == null) return;
    await change(lastUsedExtractor);
  }

//Change will set the new extractor in a persistent storage for convenience and pull the data from the extractor from tenka

  Future<void> change(final TenkaMetadata nMetadata) async {
    metadata = nMetadata;
    extractor = await TenkaManager.getExtractor(metadata!);
    notifyListeners();

    await setLastUsedExtractor(type, id: metadata!.id);
    await fetch();
  }

  Future<List<SearchInfo>> search(final String terms) async {
    switch (type) {
      case TenkaType.anime:
        final AnimeExtractor extractor = await getCastedExtractor();
        return extractor.search(terms, extractor.defaultLocale);

      case TenkaType.manga:
        final MangaExtractor extractor = await getCastedExtractor();
        return extractor.search(terms, extractor.defaultLocale);
    }
  }

//Fetch was likely was supposed to either decide whether to run fetchanime or an undefined fetchmanga

  Future<void> fetch() async {}

  Future<void> fetchAnime() async {
    searches.waiting();
    computed.waiting();
    notifyListeners();

    final AnimeExtractor extractor = await getCastedExtractor();
    try {
      searches.finish(
        await extractor.search(
          media.titleRomaji,
          extractor.defaultLocale,
        ),
      );
    } catch (error, stackTrace) {
      searches.fail(error, stackTrace);
      computed.fail('Failed to fetch search results');
    }
    notifyListeners();
    if (searches.hasFailed) return;

    final String? lastComputedUrl = await getLastComputed(
      type: type,
      id: metadata!.id,
      mediaId: media.id,
    );
    final dynamic computedSearchInfo = (lastComputedUrl != null
            ? searches.value.firstWhereOrNull(
                (final SearchInfo x) => x.url == lastComputedUrl,
              )
            : null) ??
        IterableExtension(searches.value).firstOrNull;
    if (computedSearchInfo == null) {
      computed.fail('Failed to find valid result');
    }

    try {
      searches.finish(
        await extractor.search(
          media.titleRomaji,
          extractor.defaultLocale,
        ),
      );
    } catch (error) {
      computed.fail('Failed to fetch search results');
    }
    notifyListeners();
  }

  T getCastedExtractor<T>() => extractor as T;

  TenkaType get type => media.type.asTenkaType;

  List<TenkaMetadata> get extensions => TenkaManager.repository.installed.values
      .where((final TenkaMetadata x) => x.type == media.type.asTenkaType)
      .toList();

  static String getLastUsedExtractorKey(final TenkaType type) =>
      'view_last_used_${type.name}_extractor';

  static Future<String?> getLastUsedExtractor(final TenkaType type) async {
    final String? value =
        await CacheDatabase.get<String?>(getLastUsedExtractorKey(type));
    return TenkaManager.repository.installed.containsKey(value) ? value : null;
  }

  static Future<void> setLastUsedExtractor(
    final TenkaType type, {
    required final String id,
  }) async {
    await CacheDatabase.set(getLastUsedExtractorKey(type), id);
  }

  static String getLastComputedKey({
    required final TenkaType type,
    required final String id,
    required final int mediaId,
  }) =>
      'view_last_computed_${type.name}_${id}_$mediaId';

  static Future<String?> getLastComputed({
    required final TenkaType type,
    required final String id,
    required final int mediaId,
  }) async =>
      CacheDatabase.get<String?>(
        getLastComputedKey(
          type: type,
          id: id,
          mediaId: mediaId,
        ),
      );

  static Future<void> setLastComputed({
    required final TenkaType type,
    required final String id,
    required final int mediaId,
    required final int url,
  }) async {
    await CacheDatabase.set(
      getLastComputedKey(
        type: type,
        id: id,
        mediaId: mediaId,
      ),
      url,
    );
  }
}
