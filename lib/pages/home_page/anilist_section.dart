import 'dart:ui';
import 'package:animations/animations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../core/trackers/anilist/anilist.dart' as anilist;
import '../../plugins/helpers/stateful_holder.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/helpers/utils/string.dart';
import '../../plugins/translator/translator.dart';
import '../store_page/trackers_page/anilist_page/detailed_item.dart';

final StatefulHolder<List<anilist.Media>?> _cache =
    StatefulHolder<List<anilist.Media>?>(null);

bool enabled() => anilist.AnilistManager.auth.isValidToken();

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  final Duration animationDuration = const Duration(milliseconds: 300);
  final Duration fastAnimationDuration = const Duration(milliseconds: 150);

  int? recommendedHoverIndex;
  final Map<int, StatefulHolder<anilist.MediaList?>> mediaCache =
      <int, StatefulHolder<anilist.MediaList?>>{};

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(Duration.zero, () async {
      _cache
          .resolve(await anilist.getRecommended(0, perPage: 14, onList: false));
      if (mounted) {
        setState(() {});
      }
    });
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
            ...getGridded(
              MediaQuery.of(context).size.width.toInt(),
              _cache.value!
                  .asMap()
                  .map(
                    (final int i, final anilist.Media x) =>
                        MapEntry<int, Widget>(
                      i,
                      OpenContainer(
                        transitionType: ContainerTransitionType.fadeThrough,
                        openColor: Theme.of(context).scaffoldBackgroundColor,
                        closedColor: Colors.transparent,
                        closedElevation: 0,
                        transitionDuration: animationDuration,
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
                              return DetailedItem(
                                media: mediaCache[x.id]!.value!,
                              );
                            }

                            if (mediaCache[x.id] == null) {
                              mediaCache[x.id] =
                                  StatefulHolder<anilist.MediaList?>(null);

                              anilist
                                  .getUserInfo()
                                  .then((final anilist.UserInfo user) {
                                anilist.MediaList.tryGetFromMediaId(
                                  x.id,
                                  user.id,
                                ).then((final anilist.MediaList? m) {
                                  if (mounted) {
                                    setState(() {
                                      mediaCache[x.id]!.resolve(
                                        m ??
                                            anilist.MediaList.partial(
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
                                      Text(
                                        StringUtils.capitalize(x.type.type),
                                        style:
                                            Theme.of(context).textTheme.caption,
                                      ),
                                      Text(
                                        x.titleUserPreferred,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
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
                                      duration: fastAnimationDuration,
                                      child: AnimatedScale(
                                        alignment: Alignment.topCenter,
                                        curve: Curves.easeInOut,
                                        scale: recommendedHoverIndex == i
                                            ? 1
                                            : 0.95,
                                        duration: fastAnimationDuration,
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
