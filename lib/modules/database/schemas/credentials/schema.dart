import 'dart:convert';
import 'package:objectbox/objectbox.dart';
import '../../../trackers/anilist/anilist.dart';
import '../../../trackers/myanimelist/myanimelist.dart';

@Entity()
class CredentialsSchema {
  CredentialsSchema({
    final this.anilist_,
    final this.myanimelist_,
  });

  int id = 0;

  String? anilist_;

  AniListTokenInfo? get anilist => anilist_ != null
      ? AniListTokenInfo.fromJson(
          json.decode(anilist_!) as Map<dynamic, dynamic>,
        )
      : null;

  set anilist(final AniListTokenInfo? val) {
    anilist_ = val != null ? json.encode(val.toJson()) : null;
  }

  String? myanimelist_;

  MyAnimeListTokenInfo? get myanimelist => myanimelist_ != null
      ? MyAnimeListTokenInfo.fromJson(
          json.decode(anilist_!) as Map<dynamic, dynamic>,
        )
      : null;

  set myanimelist(final MyAnimeListTokenInfo? val) {
    myanimelist_ = val != null ? json.encode(val.toJson()) : null;
  }
}
