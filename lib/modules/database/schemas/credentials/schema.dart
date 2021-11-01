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

  AniListTokenInfo? get anilist {
    if (anilist_ != null) {
      final dynamic parsed = json.decode(anilist_!);

      if (parsed is Map<dynamic, dynamic>) {
        return AniListTokenInfo.fromJson(parsed);
      }
    }
  }

  set anilist(final AniListTokenInfo? val) {
    anilist_ = val != null ? json.encode(val.toJson()) : null;
  }

  String? myanimelist_;

  MyAnimeListTokenInfo? get myanimelist {
    if (myanimelist_ != null) {
      final dynamic parsed = json.decode(myanimelist_!);

      if (parsed is Map<dynamic, dynamic>) {
        return MyAnimeListTokenInfo.fromJson(parsed);
      }
    }
  }

  set myanimelist(final MyAnimeListTokenInfo? val) {
    myanimelist_ = val != null ? json.encode(val.toJson()) : null;
  }
}
