import './auth.dart';
import '../../../plugins/database/database.dart';
import '../../secrets/anilist.dart';

class UserInfo {
  UserInfo({
    required final this.id,
    required final this.name,
    required final this.avatarMedium,
  });

  factory UserInfo.fromJson(final Map<dynamic, dynamic> json) => UserInfo(
        id: json['id'] as int,
        name: json['name'] as String,
        avatarMedium: json['avatar']['medium'] as String,
      );

  int id;
  String name;
  String avatarMedium;
}

class Media {
  Media({
    required final this.id,
    required final this.idMal,
    required final this.titleUserPreferred,
    required final this.type,
    required final this.episodes,
    required final this.coverImageMedium,
    required final this.genres,
    required final this.meanScore,
    required final this.siteUrl,
  });

  factory Media.fromJson(final Map<dynamic, dynamic> json) => Media(
        id: json['id'] as int,
        idMal: json['idMal'] as int,
        titleUserPreferred: json['titleUserPreferred'] as String,
        type: json['type'] as String,
        episodes: json['episodes'] as int,
        coverImageMedium: json['coverImageMedium'] as String,
        genres: json['genres'] as List<String>,
        meanScore: json['meanScore'] as int,
        siteUrl: json['siteUrl'] as String,
      );

  final int id;
  final int idMal;
  final String titleUserPreferred;
  final String type;
  final int? episodes;
  final String coverImageMedium;
  final List<String> genres;
  final int meanScore;
  final String siteUrl;
}

class AnimeList {
  AnimeList({
    required final this.userId,
    required final this.status,
    required final this.progress,
    required final this.startedAt,
    required final this.completedAt,
    required final this.media,
  });

  factory AnimeList.fromJson(final Map<dynamic, dynamic> json) => AnimeList(
        userId: json['userId'] as int,
        status: json['status'] as String,
        progress: json['progress'] as int,
        startedAt: json['startedAt'] as DateTime,
        completedAt: json['completedAt'] as DateTime,
        media: Media.fromJson(json['media'] as Map<dynamic, dynamic>),
      );

  final int userId;
  final String status;
  final int progress;
  final DateTime startedAt;
  final DateTime completedAt;
  final Media media;
}

class AnimeSearch {
  AnimeSearch({
    required final this.id,
    required final this.idMal,
    required final this.titleUserPreferred,
    required final this.coverImageMedium,
  });

  final int id;
  final int idMal;
  final String titleUserPreferred;
  final String coverImageMedium;
}

abstract class MyAnimeListManager {
  static const String webURL = 'https://anilist.co';
  static const String baseURL = 'https://graphql.anilist.co';

  static final Auth auth = Auth(AnilistSecrets.clientId);
  static UserInfo? cachedUser;

  Future<void> initialize() async {
    final Map<dynamic, dynamic>? token = DataStore.credentials.anilist;

    if (token != null) {
      auth.token = TokenInfo.fromJson(token);
    }
  }

  bool get isLoggedIn => auth.isValidToken();

  // Future<void> authenticate(final TokenInfo token) async {
  //     final res = await auth.authorize(token);
  //     // if (this.auth.token) await this.storeToken();
  //     return res;
  // }

  // async storeToken() {
  //     if (!this.auth.token) return false;

  //     const store = await Store.getClient();
  //     await store.set(StoreKeys.aniListToken, this.auth.token);
  // }

  // async removeToken() {
  //     const store = await Store.getClient();
  //     await store.set(StoreKeys.aniListToken, null);
  // }

  // async userInfo() {
  //     const res = await this.request({
  //         query: `
  //             {
  //                 Viewer {
  //                     id,
  //                     name,
  //                     avatar {
  //                         medium
  //                     }
  //                 }
  //             }
  //         `,
  //     });
  //     const user: UserInfoEntity | null =
  //         (res && JSON.parse(res)?.data?.Viewer) || null;
  //     if (user) this.cachedUser = user;
  //     return user;
  // }

  // async animelist(status?: StatusType, page: number = 0) {
  //     const perpage = 100;
  //     const res = await this.request({
  //         query: `
  //             query (
  //                 $userId: Int,
  //                 $type: MediaType,
  //                 $status: [MediaListStatus],
  //                 $page: Int,
  //                 $perpage: Int
  //             ) {
  //                 Page (page: $page, perPage: $perpage) {
  //                     mediaList (userId: $userId, type: $type, status_in: $status) {
  //                         userId,
  //                         status,
  //                         progress,
  //                         startedAt {
  //                             day,
  //                             month,
  //                             year
  //                         },
  //                         completedAt {
  //                             day,
  //                             month,
  //                             year
  //                         },
  //                         media {
  //                             id,
  //                             idMal,
  //                             title {
  //                                 userPreferred
  //                             },
  //                             type,
  //                             episodes,
  //                             coverImage {
  //                                 medium
  //                             },
  //                             genres,
  //                             meanScore,
  //                             siteUrl
  //                         }
  //                     }
  //                 }
  //             }
  //             `,
  //         variables: {
  //             userId: this.cachedUser?.id || (await this.userInfo())?.id,
  //             type: "ANIME",
  //             status: status || Status,
  //             page,
  //             perpage,
  //         },
  //     });
  //     return <AnimeListEntity[]>(
  //         ((res && JSON.parse(res)?.data?.Page?.mediaList) || [])
  //     );
  // }

  // async getAnime(id: number) {
  //     const res = await this.request({
  //         query: `
  //             query ($mediaId: Int, $userId: Int) {
  //                 MediaList (mediaId: $mediaId, userId: $userId) {
  //                     id,
  //                     status,
  //                     progress,
  //                     media {
  //                         id,
  //                         idMal,
  //                         title {
  //                             userPreferred
  //                         },
  //                         episodes
  //                     }
  //                 }
  //             }
  //         `,
  //         variables: {
  //             userId: this.cachedUser?.id || (await this.userInfo())?.id,
  //             mediaId: id,
  //         },
  //     });
  //     return <GetAnimeEntity | null>(
  //         ((res && JSON.parse(res)?.data?.MediaList) || null)
  //     );
  // }

  // async getAnimeGeneric(id: number) {
  //     const res = await this.request({
  //         query: `
  //             query ($mediaId: Int) {
  //                 Media (id: $mediaId) {
  //                     id,
  //                     idMal,
  //                     title {
  //                         userPreferred
  //                     }
  //                     coverImage {
  //                         medium
  //                     }
  //                     episodes,
  //                     genres
  //                 }
  //             }
  //         `,
  //         variables: {
  //             mediaId: id,
  //         },
  //     });
  //     return <GetAnimeGenericEntity | null>(
  //         ((res && JSON.parse(res)?.data?.Media) || null)
  //     );
  // }

  // async updateAnime(id: number, body: Partial<AnimeUpdateBody>) {
  //     const res = await this.request({
  //         query: `
  //             mutation ($mediaId: Int, $progress: Int, $status: MediaListStatus) {
  //                 SaveMediaListEntry (mediaId: $mediaId, progress: $progress, status: $status) {
  //                     id,
  //                     status,
  //                     progress,
  //                     media {
  //                         id,
  //                         idMal,
  //                         title {
  //                             userPreferred
  //                         },
  //                         episodes
  //                     }
  //                 }
  //             }
  //         `,
  //         variables: {
  //             mediaId: id,
  //             ...body,
  //         },
  //     });
  //     return <GetAnimeEntity | null>(
  //         ((res && JSON.parse(res)?.data?.SaveMediaListEntry) || null)
  //     );
  // }

  // async searchAnime(title: string) {
  //     const res = await this.request({
  //         query: `
  //             query ($search: String, $type: MediaType, $page: Int, $perPage: Int) {
  //                 Page (page: $page, perPage: $perPage) {
  //                     media (search: $search, type: $type) {
  //                         id,
  //                         idMal,
  //                         title {
  //                             userPreferred
  //                         }
  //                         coverImage {
  //                             medium
  //                         }
  //                     }
  //                 }
  //             }
  //         `,
  //         variables: {
  //             search: title,
  //             type: "ANIME",
  //             page: 0,
  //             perPage: 20,
  //         },
  //     });
  //     return <AnimeSearchEntity[]>(
  //         ((res && JSON.parse(res)?.data?.Page?.media) || [])
  //     );
  // }

  // async mangalist(status?: StatusType, page: number = 0) {
  //     const perpage = 100;
  //     const res = await this.request({
  //         query: `
  //             query (
  //                 $userId: Int,
  //                 $type: MediaType,
  //                 $status: [MediaListStatus],
  //                 $page: Int,
  //                 $perpage: Int
  //             ) {
  //                 Page (page: $page, perPage: $perpage) {
  //                     mediaList (userId: $userId, type: $type, status_in: $status) {
  //                         userId,
  //                         status,
  //                         progress,
  //                         progressVolumes,
  //                         startedAt {
  //                             day,
  //                             month,
  //                             year
  //                         },
  //                         completedAt {
  //                             day,
  //                             month,
  //                             year
  //                         },
  //                         media {
  //                             id,
  //                             idMal,
  //                             title {
  //                                 userPreferred
  //                             },
  //                             type,
  //                             chapters,
  //                             volumes,
  //                             coverImage {
  //                                 medium
  //                             },
  //                             genres,
  //                             meanScore,
  //                             siteUrl
  //                         }
  //                     }
  //                 }
  //             }
  //             `,
  //         variables: {
  //             userId: this.cachedUser?.id || (await this.userInfo())?.id,
  //             type: "MANGA",
  //             status: status || Status,
  //             page,
  //             perpage,
  //         },
  //     });
  //     return <MangaListEntity[]>(
  //         ((res && JSON.parse(res)?.data?.Page?.mediaList) || [])
  //     );
  // }

  // async getManga(id: number) {
  //     const res = await this.request({
  //         query: `
  //             query ($mediaId: Int, $userId: Int) {
  //                 MediaList (mediaId: $mediaId, userId: $userId) {
  //                     id,
  //                     status,
  //                     progress,
  //                     progressVolumes,
  //                     media {
  //                         id,
  //                         idMal,
  //                         title {
  //                             userPreferred
  //                         },
  //                         chapters,
  //                         volumes
  //                     }
  //                 }
  //             }
  //         `,
  //         variables: {
  //             userId: this.cachedUser?.id || (await this.userInfo())?.id,
  //             mediaId: id,
  //         },
  //     });
  //     return <GetMangaEntity | null>(
  //         ((res && JSON.parse(res)?.data?.MediaList) || null)
  //     );
  // }

  // async getMangaGeneric(id: number) {
  //     const res = await this.request({
  //         query: `
  //             query ($mediaId: Int) {
  //                 Media (id: $mediaId) {
  //                     id,
  //                     idMal,
  //                     title {
  //                         userPreferred
  //                     }
  //                     coverImage {
  //                         medium
  //                     }
  //                     chapters,
  //                     volumes,
  //                     genres
  //                 }
  //             }
  //         `,
  //         variables: {
  //             mediaId: id,
  //         },
  //     });
  //     return <GetMangaGenericEntity | null>(
  //         ((res && JSON.parse(res)?.data?.Media) || null)
  //     );
  // }

  // async updateManga(id: number, body: Partial<MangaUpdateBody>) {
  //     const res = await this.request({
  //         query: `
  //             mutation ($mediaId: Int, $progress: Int, $progressVolumes: Int, $status: MediaListStatus) {
  //                 SaveMediaListEntry (mediaId: $mediaId, progress: $progress, progressVolumes: $progressVolumes, status: $status) {
  //                     id,
  //                     status,
  //                     progress,
  //                     progressVolumes,
  //                     media {
  //                         id,
  //                         idMal,
  //                         title {
  //                             userPreferred
  //                         }
  //                     }
  //                 }
  //             }
  //         `,
  //         variables: {
  //             mediaId: id,
  //             ...body,
  //         },
  //     });
  //     return <GetMangaEntity | null>(
  //         ((res && JSON.parse(res)?.data?.SaveMediaListEntry) || null)
  //     );
  // }

  // async searchManga(title: string) {
  //     const res = await this.request({
  //         query: `
  //             query ($search: String, $type: MediaType, $page: Int, $perPage: Int) {
  //                 Page (page: $page, perPage: $perPage) {
  //                     media (search: $search, type: $type) {
  //                         id,
  //                         idMal,
  //                         title {
  //                             userPreferred
  //                         }
  //                         coverImage {
  //                             medium
  //                         }
  //                     }
  //                 }
  //             }
  //         `,
  //         variables: {
  //             search: title,
  //             type: "MANGA",
  //             page: 0,
  //             perPage: 20,
  //         },
  //     });
  //     return <MangaSearchEntity[]>(
  //         ((res && JSON.parse(res)?.data?.Page?.media) || [])
  //     );
  // }

  // async request(query?: any) {
  //     if (!this.auth.token) return false;

  //     try {
  //         const client = await http.getClient();
  //         const res = await client.post(this.baseURL, JSON.stringify(query), {
  //             headers: {
  //                 Authorization: `${this.auth.token.token_type} ${this.auth.token.access_token}`,
  //                 "Content-Type": "application/json",
  //                 Accept: "application/json",
  //             },
  //             responseType: "text",
  //         });

  //         const parsed = JSON.parse(res);
  //         if (
  //             parsed.errors?.some((x: any) => x.message === "Invalid token")
  //         ) {
  //             this.logout();
  //             throw new Error("Session expired");
  //         }

  //         return res;
  //     } catch (err: any) {
  //         throw err;
  //     }
  // }

  // async logout() {
  //     this.auth.setToken(null);
  //     await this.removeToken();
  // }
}
