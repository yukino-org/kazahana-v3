import 'package:collection/collection.dart';
import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import '../../../modules/database/database.dart';
import '../../../modules/extensions/extensions.dart';
import '../../../modules/state/stateful_holder.dart';
import '../../../modules/translator/translator.dart';
import '../../models/controller.dart';
import '../../router.dart';
import '../anime_page/controller.dart';
import '../manga_page/controller.dart';

class SearchPageArguments {
  SearchPageArguments({
    final this.terms,
    final this.autoSearch,
    final this.pluginType,
    final this.pluginId,
  });

  factory SearchPageArguments.fromJson(final Map<String, String> json) =>
      SearchPageArguments(
        terms: json['terms'],
        autoSearch: json['autoSearch'] == 'true',
        pluginType: ExtensionType.values.firstWhereOrNull(
          (final ExtensionType x) => x.type == json['pluginType'],
        ),
        pluginId: json['pluginId'],
      );

  String? terms;
  bool? autoSearch;
  ExtensionType? pluginType;
  String? pluginId;

  Map<String, String> toJson() {
    final Map<String, String> json = <String, String>{};

    if (terms != null) {
      json['terms'] = terms!;
    }

    if (autoSearch != null) {
      json['autoSearch'] = autoSearch.toString();
    }

    if (pluginType != null) {
      json['pluginType'] = pluginType!.type;
    }

    if (pluginId != null) {
      json['pluginId'] = pluginId!;
    }

    return json;
  }
}

extension PluginRoutes on ExtensionType {
  String get route {
    switch (this) {
      case ExtensionType.anime:
        return RouteNames.animePage;

      case ExtensionType.manga:
        return RouteNames.mangaPage;
    }
  }

  Map<String, String> constructQuery({
    required final String plugin,
    required final String src,
  }) {
    switch (this) {
      case ExtensionType.anime:
        return AnimePageArguments(src: src, plugin: plugin).toJson();

      case ExtensionType.manga:
        return MangaPageArguments(src: src, plugin: plugin).toJson();
    }
  }
}

class CurrentPlugin {
  const CurrentPlugin({
    required final this.type,
    required final this.plugin,
  });

  final ExtensionType type;
  final BaseExtractor plugin;

  CurrentPlugin copyWith({
    final ExtensionType? type,
    final BaseExtractor? plugin,
  }) =>
      CurrentPlugin(
        type: type ?? this.type,
        plugin: plugin ?? this.plugin,
      );
}

class SearchResult {
  const SearchResult({
    required final this.info,
    required final this.plugin,
  });

  final SearchInfo info;
  final CurrentPlugin plugin;
}

class SearchPageController extends Controller<SearchPageController> {
  SearchPageArguments? args;
  StatefulValueHolderWithError<List<SearchResult>?> results =
      StatefulValueHolderWithError<List<SearchResult>?>(null);

  final TextEditingController searchTextController = TextEditingController();
  CurrentPlugin? currentPlugin;

  @override
  Future<void> setup() async {
    final CachedPreferencesSchema preferences = CachedPreferencesBox.get();
    final ExtensionType type =
        preferences.lastSelectedSearch?.lastSelectedType ?? ExtensionType.anime;

    BaseExtractor? plugin;
    switch (type) {
      case ExtensionType.anime:
        plugin = ExtensionsManager.animes[
                preferences.lastSelectedSearch?.lastSelectedAnimePlugin ??
                    ''] ??
            ExtensionsManager.animes.values.firstOrNull;
        break;

      case ExtensionType.manga:
        plugin = ExtensionsManager.mangas[
                preferences.lastSelectedSearch?.lastSelectedMangaPlugin ??
                    ''] ??
            ExtensionsManager.mangas.values.firstOrNull;
        break;
    }

    if (plugin != null) {
      setCurrentPlugin(CurrentPlugin(type: type, plugin: plugin));
    }

    await super.setup();
  }

  @override
  Future<void> dispose() async {
    searchTextController.dispose();

    await super.dispose();
  }

  Future<void> onInitState(final BuildContext context) async {
    args = SearchPageArguments.fromJson(
      ParsedRouteInfo.fromSettings(ModalRoute.of(context)!.settings).params,
    );

    if (args?.terms != null) {
      searchTextController.value = TextEditingValue(text: args!.terms!);
    }

    if (args?.pluginType != null) {
      BaseExtractor? plugin;
      switch (args!.pluginType!) {
        case ExtensionType.anime:
          plugin = ExtensionsManager.animes[args!.pluginId!];
          break;

        case ExtensionType.manga:
          plugin = ExtensionsManager.mangas[args!.pluginId!];
          break;
      }

      if (plugin != null) {
        setCurrentPlugin(
          CurrentPlugin(type: args!.pluginType!, plugin: plugin),
        );
      }
    }
  }

  Future<void> setCurrentPlugin(final CurrentPlugin? plugin) async {
    currentPlugin = plugin;

    if (plugin != null) {
      final CachedPreferencesSchema preferences = CachedPreferencesBox.get();
      preferences.lastSelectedSearch =
          (preferences.lastSelectedSearch ?? const LastSelectedSearchPlugin())
              .copyWith(
        lastSelectedType: plugin.type,
        lastSelectedAnimePlugin:
            plugin.type == ExtensionType.anime ? plugin.plugin.id : null,
        lastSelectedMangaPlugin:
            plugin.type == ExtensionType.manga ? plugin.plugin.id : null,
      );
      await CachedPreferencesBox.save(preferences);
    }

    reassemble();

    if (currentPlugin != null &&
        searchTextController.value.text.isNotEmpty &&
        (args?.autoSearch ?? false)) {
      args!.autoSearch = false;
      await search();
    }
  }

  Future<void> search() async {
    if (currentPlugin == null) {
      throw Exception('No plugin has been selected');
    }

    results.resolving(null);
    reassemble();

    try {
      final List<SearchInfo> searches = await currentPlugin!.plugin.search(
        searchTextController.text,
        Translator.t.locale,
      );

      results.resolve(
        searches
            .map(
              (final SearchInfo x) => SearchResult(
                info: x,
                plugin: currentPlugin!,
              ),
            )
            .toList(),
      );
    } catch (err, stack) {
      results.failUnknown(null, err, stack);
    }

    reassemble();
  }
}
