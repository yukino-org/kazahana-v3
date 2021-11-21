import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:utilx/utilities/utils.dart';
import '../../../../../modules/helpers/ui.dart';
import '../../../../../modules/trackers/anilist/anilist.dart';
import '../../../../../modules/translator/translator.dart';
import '../../../../components/trackers/media_list.dart';
import '../../../../components/trackers/profile_page.dart';
import '../../../../router.dart';

class PageArguments {
  PageArguments({
    required final this.type,
  });

  factory PageArguments.fromJson(final Map<String, String> json) {
    if (json['type'] == null) {
      throw ArgumentError("Got null value for 'type'");
    }

    return PageArguments(
      type: ExtensionType.values.firstWhere(
        (final ExtensionType type) => type.type == json['type'],
      ),
    );
  }

  ExtensionType type;

  Map<String, String> toJson() => <String, String>{
        'type': type.type,
      };
}

class Page extends StatelessWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) => ProfilePage(
        title: () {
          final PageArguments args = PageArguments.fromJson(
            ParsedRouteInfo.fromSettings(ModalRoute.of(context)!.settings)
                .params,
          );

          return '${Translator.t.anilist()} - ${StringUtils.capitalize(args.type.type)}';
        },
        tabs: AniListMediaListStatus.values
            .map(
              (final AniListMediaListStatus x) =>
                  PageTab(x, StringUtils.capitalize(x.pretty)),
            )
            .toList(),
        profile: ProfileTab(
          getLeft: (final dynamic _user) {
            final AniListUserInfo user = _user as AniListUserInfo;

            return Material(
              shape: const CircleBorder(),
              elevation: 5,
              child: CircleAvatar(
                radius: remToPx(2.5),
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(
                  user.avatarMedium,
                ),
              ),
            );
          },
          getMid: (final dynamic _user) {
            final AniListUserInfo user = _user as AniListUserInfo;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headline4?.copyWith(
                        color: Theme.of(context).textTheme.overline?.color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'ID: ${user.id}',
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            );
          },
          getRight: (final dynamic _user, final void Function() pop) =>
              Material(
            type: MaterialType.transparency,
            elevation: 2,
            color: Colors.white,
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.red[400],
                borderRadius: BorderRadius.circular(remToPx(0.2)),
              ),
              child: InkWell(
                onTap: () async {
                  await AnilistManager.auth.deleteToken();
                  pop();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: remToPx(0.5),
                    vertical: remToPx(0.2),
                  ),
                  child: Text(
                    Translator.t.logOut(),
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
        getUserInfo: () async => AniListUserInfo.getUserInfo(),
        getMediaList: (final PageTab tab) {
          final PageArguments args = PageArguments.fromJson(
            ParsedRouteInfo.fromSettings(ModalRoute.of(context)!.settings)
                .params,
          );
          final AniListMediaListStatus status =
              tab.data as AniListMediaListStatus;

          return MediaList(
            type: args.type,
            status: status,
            getMediaList: (final int page) async =>
                getMediaList(args.type, status, page),
            getItemCard: (final BuildContext context, final dynamic _item) {
              final AniListMediaList x = _item as AniListMediaList;

              return Card(
                child: Padding(
                  padding: EdgeInsets.all(remToPx(0.3)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: remToPx(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            remToPx(0.25),
                          ),
                          child: Image.network(
                            x.media.coverImageMedium,
                          ),
                        ),
                      ),
                      SizedBox(width: remToPx(0.75)),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              x.media.titleUserPreferred,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .fontSize! -
                                    remToPx(0.1),
                              ),
                            ),
                            SizedBox(
                              height: remToPx(0.1),
                            ),
                            RichText(
                              text: TextSpan(
                                children: <InlineSpan>[
                                  TextSpan(
                                    text:
                                        '${Translator.t.progress()}: ${x.progress}',
                                  ),
                                  if (x.startedAt != null)
                                    TextSpan(
                                      text:
                                          ' (${x.startedAt.toString().split(' ').first})',
                                    ),
                                  TextSpan(
                                    text:
                                        ' / ${x.media.episodes ?? x.media.chapters ?? '?'}',
                                  ),
                                  if (x.completedAt != null)
                                    TextSpan(
                                      text:
                                          ' (${x.completedAt.toString().split(' ').first})',
                                    ),
                                ],
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            getItemPage: (final BuildContext context, final dynamic _item) {
              final AniListMediaList x = _item as AniListMediaList;

              return x.getDetailedPage(context);
            },
          );
        },
      );
}
