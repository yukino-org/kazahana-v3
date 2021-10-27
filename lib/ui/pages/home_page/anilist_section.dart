import 'package:animations/animations.dart';
import 'package:extensions/extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../config/defaults.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/state/holder.dart';
import '../../../modules/state/loader.dart';
import '../../../modules/trackers/anilist/anilist.dart';
import '../../../modules/translator/translator.dart';
import '../../../modules/utils/utils.dart';

final StatefulValueHolder<List<AniListMedia>?> _cache =
    StatefulValueHolder<List<AniListMedia>?>(null);

bool enabled() => AnilistManager.auth.isValidToken();

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> with InitialStateLoader {
  int? recommendedHoverIndex;
  final Map<int, StatefulValueHolder<AniListMediaList?>> mediaCache =
      <int, StatefulValueHolder<AniListMediaList?>>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    maybeLoad();
  }

  @override
  Future<void> load() async {
    _cache.resolve(
      await AniListRecommendations.getRecommended(
        0,
        perPage: 14,
        onList: false,
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(final BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            Translator.t.recommendedBy(Translator.t.anilist()),
            style: Theme.of(context).textTheme.headline5?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(
            height: remToPx(0.3),
          ),
          if (_cache.hasResolved)
            ...UiUtils.getGridded(
              MediaQuery.of(context).size.width.toInt(),
              _cache.value!
                  .asMap()
                  .map(
                    (final int i, final AniListMedia x) =>
                        MapEntry<int, Widget>(
                      i,
                      OpenContainer(
                        transitionType: ContainerTransitionType.fadeThrough,
                        openColor: Theme.of(context).scaffoldBackgroundColor,
                        closedColor: Colors.transparent,
                        closedElevation: 0,
                        transitionDuration: Defaults.animationsSlower,
                        onClosed: (final dynamic result) {
                          setState(() {
                            recommendedHoverIndex = null;
                          });
                        },
                        openBuilder: (
                          final BuildContext context,
                          final VoidCallback cb,
                        ) =>
                            StatefulBuilder(
                          builder: (
                            final BuildContext context,
                            final StateSetter setState,
                          ) {
                            if (mediaCache[x.id]?.hasResolved ?? false) {
                              return mediaCache[x.id]!
                                  .value!
                                  .getDetailedPage(context);
                            }

                            if (mediaCache[x.id] == null) {
                              mediaCache[x.id] =
                                  StatefulValueHolder<AniListMediaList?>(null);

                              AniListUserInfo.getUserInfo()
                                  .then((final AniListUserInfo user) {
                                AniListMediaList.tryGetFromMediaId(
                                  x.id,
                                  user.id,
                                ).then((final AniListMediaList? m) {
                                  if (mounted) {
                                    setState(() {
                                      mediaCache[x.id]!.resolve(
                                        m ??
                                            AniListMediaList.partial(
                                              userId: user.id,
                                              media: x,
                                            ),
                                      );
                                    });
                                  }
                                });
                              });
                            }

                            return Scaffold(
                              appBar: AppBar(),
                              body: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                        closedBuilder: (
                          final BuildContext context,
                          final VoidCallback cb,
                        ) =>
                            MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (final PointerEnterEvent event) {
                            setState(() {
                              recommendedHoverIndex = i;
                            });
                          },
                          onExit: (final PointerExitEvent event) {
                            setState(() {
                              recommendedHoverIndex = null;
                            });
                          },
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(remToPx(0.4)),
                                  child: Column(
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          remToPx(0.3),
                                        ),
                                        child: Image.network(
                                          x.coverImageExtraLarge,
                                        ),
                                      ),
                                      SizedBox(
                                        height: remToPx(0.4),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          children: <InlineSpan>[
                                            TextSpan(
                                              text: StringUtils.capitalize(
                                                x.type.type,
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption,
                                            ),
                                            TextSpan(
                                              text: '\n${x.titleUserPreferred}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                if (x.description != null)
                                  Positioned.fill(
                                    child: AnimatedOpacity(
                                      curve: Curves.easeInOut,
                                      opacity:
                                          recommendedHoverIndex == i ? 1 : 0,
                                      duration: Defaults.animationsFast,
                                      child: AnimatedScale(
                                        alignment: Alignment.topCenter,
                                        curve: Curves.easeInOut,
                                        scale: recommendedHoverIndex == i
                                            ? 1
                                            : 0.95,
                                        duration: Defaults.animationsFast,
                                        child: Container(
                                          color: Theme.of(context)
                                              .cardColor
                                              .withOpacity(0.9),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                              remToPx(0.4),
                                            ),
                                            child: Text(
                                              x.description!.replaceAll(
                                                RegExp('<br[ /]*>'),
                                                '\n',
                                              ),
                                              overflow: TextOverflow.fade,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned.fill(
                                  child: GestureDetector(
                                    onTap: recommendedHoverIndex != i
                                        ? () {
                                            setState(() {
                                              recommendedHoverIndex = i;
                                            });
                                          }
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .values
                  .toList(),
              breakpoint: <int, int>{
                0: 2,
                ResponsiveSizes.xs: 3,
                ResponsiveSizes.md: 4,
                ResponsiveSizes.lg: 7,
              },
              crossAxisAlignment: CrossAxisAlignment.start,
            )
          else
            SizedBox(
              height: remToPx(8),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      );
}
