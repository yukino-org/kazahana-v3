import 'dart:convert';
import 'package:extensions/extensions.dart';
import 'package:objectbox/objectbox.dart';

class LastSelectedSearchPlugin {
  LastSelectedSearchPlugin({
    this.lastSelectedType,
    this.lastSelectedAnimePlugin,
    this.lastSelectedMangaPlugin,
  });

  factory LastSelectedSearchPlugin.fromJson(final Map<dynamic, dynamic> json) =>
      LastSelectedSearchPlugin(
        lastSelectedType: json['lastSelectedType'] != null
            ? ExtensionType.values.firstWhere(
                (final ExtensionType x) => x.name == json['lastSelectedType'],
              )
            : null,
        lastSelectedAnimePlugin: json['lastSelectedAnimePlugin'] as String?,
        lastSelectedMangaPlugin: json['lastSelectedMangaPlugin'] as String?,
      );

  ExtensionType? lastSelectedType;
  String? lastSelectedAnimePlugin;
  String? lastSelectedMangaPlugin;

  bool get isEmpty =>
      lastSelectedType == null &&
      lastSelectedAnimePlugin == null &&
      lastSelectedMangaPlugin == null;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'lastSelectedType': lastSelectedType?.name,
        'lastSelectedAnimePlugin': lastSelectedAnimePlugin,
        'lastSelectedMangaPlugin': lastSelectedMangaPlugin,
      };
}

@Entity()
class PreferencesSchema {
  PreferencesSchema({
    final this.lastSelectedSearch_,
  });

  int id = 0;

  String? lastSelectedSearch_;

  LastSelectedSearchPlugin get lastSelectedSearch => lastSelectedSearch_ != null
      ? LastSelectedSearchPlugin.fromJson(
          json.decode(lastSelectedSearch_!) as Map<dynamic, dynamic>,
        )
      : LastSelectedSearchPlugin();

  set lastSelectedSearch(final LastSelectedSearchPlugin? val) {
    lastSelectedSearch_ = val != null ? json.encode(val.toJson()) : null;
  }
}
