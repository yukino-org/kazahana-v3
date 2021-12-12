import 'dart:convert';
import 'package:extensions/extensions.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectbox/objectbox.dart';

part 'schema.g.dart';

@JsonSerializable()
class LastSelectedSearchPlugin {
  const LastSelectedSearchPlugin({
    final this.lastSelectedType,
    final this.lastSelectedAnimePlugin,
    final this.lastSelectedMangaPlugin,
  });

  factory LastSelectedSearchPlugin.fromJson(final Map<dynamic, dynamic> json) =>
      _$LastSelectedSearchPluginFromJson(json.cast<String, dynamic>());

  final ExtensionType? lastSelectedType;
  final String? lastSelectedAnimePlugin;
  final String? lastSelectedMangaPlugin;

  LastSelectedSearchPlugin copyWith({
    final ExtensionType? lastSelectedType,
    final String? lastSelectedAnimePlugin,
    final String? lastSelectedMangaPlugin,
  }) =>
      LastSelectedSearchPlugin(
        lastSelectedType: lastSelectedType ?? this.lastSelectedType,
        lastSelectedAnimePlugin:
            lastSelectedAnimePlugin ?? this.lastSelectedAnimePlugin,
        lastSelectedMangaPlugin:
            lastSelectedMangaPlugin ?? this.lastSelectedMangaPlugin,
      );

  bool get isEmpty =>
      lastSelectedType == null &&
      lastSelectedAnimePlugin == null &&
      lastSelectedMangaPlugin == null;

  Map<dynamic, dynamic> toJson() => _$LastSelectedSearchPluginToJson(this);
}

@Entity()
class CachedPreferencesSchema {
  CachedPreferencesSchema({
    final this.lastSelectedSearch,
  });

  int id = 0;

  LastSelectedSearchPlugin? lastSelectedSearch;
  String? get lastSelectedSearch_ => json.encode(lastSelectedSearch?.toJson());
  set lastSelectedSearch_(final String? nValue) {
    lastSelectedSearch = nValue != null
        ? LastSelectedSearchPlugin.fromJson(
            json.decode(nValue) as Map<dynamic, dynamic>,
          )
        : const LastSelectedSearchPlugin();
  }
}
