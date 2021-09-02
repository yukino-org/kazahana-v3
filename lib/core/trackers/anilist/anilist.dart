import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import './handlers/auth.dart';
import '../../../plugins/database/database.dart';
import '../../secrets/anilist.dart';

export './handlers/auth.dart';
export './handlers/status.dart';
export './handlers/user_info.dart';

class RequestBody {
  RequestBody({
    required final this.query,
    required final this.variables,
  });

  final dynamic query;
  final dynamic variables;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'query': query,
        'variables': variables,
      };
}

abstract class AnilistManager {
  static const String webURL = 'https://anilist.co';
  static const String baseURL = 'https://graphql.anilist.co';

  static final Auth auth = Auth(AnilistSecrets.clientId);

  static Future<void> initialize() async {
    final Map<dynamic, dynamic>? _token = DataStore.credentials.anilist;

    if (_token != null) {
      final TokenInfo token = TokenInfo.fromJson(_token);
      if (DateTime.now().isBefore(token.expiresAt)) {
        auth.token = token;
      } else {
        await auth.deleteToken();
      }
    }
  }

  static Future<void> authenticate(final TokenInfo token) async {
    auth.authorize(token);
    if (auth.token != null) {
      await auth.saveToken();
    }
  }

  static Future<dynamic> request(final RequestBody body) async {
    if (!auth.isValidToken()) throw StateError('Not logged in');

    final http.Response res = await http.post(
      Uri.parse(baseURL),
      body: json.encode(body.toJson()),
      headers: <String, String>{
        'Authorization': '${auth.token!.tokenType} ${auth.token!.accessToken}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final dynamic parsed = json.decode(res.body);
    if ((parsed['errors'] as List<dynamic>?)?.firstWhereOrNull(
          (final dynamic x) => x['message'] == 'Invalid token',
        ) !=
        null) {
      await auth.deleteToken();
      throw StateError('Login expired');
    }

    return parsed;
  }

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

  bool get isLoggedIn => auth.isValidToken();
}
