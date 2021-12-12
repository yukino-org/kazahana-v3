import 'dart:convert';
import 'package:objectbox/objectbox.dart';
import './sub_schemas/anime/anime.dart';
import './sub_schemas/developers/developers.dart';
import './sub_schemas/manga/manga.dart';
import './sub_schemas/preferences/preferences.dart';

export './sub_schemas/anime/anime.dart';
export './sub_schemas/developers/developers.dart';
export './sub_schemas/manga/manga.dart';
export './sub_schemas/preferences/preferences.dart';

@Entity()
class SettingsSchema {
  int id = 0;

  PreferencesSettingsSchema preferences = PreferencesSettingsSchema();
  String? get preferences_ => json.encode(preferences.toJson());
  set preferences_(final String? nValue) {
    preferences = nValue != null
        ? PreferencesSettingsSchema.fromJson(
            json.decode(nValue) as Map<dynamic, dynamic>,
          )
        : PreferencesSettingsSchema();
  }

  AnimeSettingsSchema anime = AnimeSettingsSchema();
  String? get anime_ => json.encode(anime.toJson());
  set anime_(final String? nValue) {
    anime = nValue != null
        ? AnimeSettingsSchema.fromJson(
            json.decode(nValue) as Map<dynamic, dynamic>,
          )
        : AnimeSettingsSchema();
  }

  MangaSettingsSchema manga = MangaSettingsSchema();
  String? get manga_ => json.encode(manga.toJson());
  set manga_(final String? nValue) {
    manga = nValue != null
        ? MangaSettingsSchema.fromJson(
            json.decode(nValue) as Map<dynamic, dynamic>,
          )
        : MangaSettingsSchema();
  }

  DevelopersSettingsSchema developers = DevelopersSettingsSchema();
  String? get developers_ => json.encode(developers.toJson());
  set developers_(final String? nValue) {
    developers = nValue != null
        ? DevelopersSettingsSchema.fromJson(
            json.decode(nValue) as Map<dynamic, dynamic>,
          )
        : DevelopersSettingsSchema();
  }
}
