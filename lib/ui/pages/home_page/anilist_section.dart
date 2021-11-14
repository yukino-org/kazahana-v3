import 'package:animations/animations.dart';
import 'package:extensions/extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../config/defaults.dart';
import '../../../modules/helpers/assets.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/state/hooks.dart';
import '../../../modules/state/stateful_holder.dart';
import '../../../modules/state/states.dart';
import '../../../modules/trackers/anilist/anilist.dart';
import '../../../modules/translator/translator.dart';
import '../../../modules/utils/utils.dart';
import '../../components/error_widget.dart';
import '../../components/network_image_fallback.dart';
import '../../components/reactive_state_builder.dart';

final StatefulValueHolderWithError<List<AniListMedia>?> _cache =
    StatefulValueHolderWithError<List<AniListMedia>?>(null);

bool enabled() => AnilistManager.auth.isValidToken();

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> with HooksMixin {
  int? recommendedHoverIndex;
  final Map<int, StatefulValueHolderWithError<AniListMediaList?>> mediaCache =
      <int, StatefulValueHolderWithError<AniListMediaList?>>{};

  @override
  void initState() {
    super.initState();

    onReady(() async {
      if (_cache.state.isWaiting) {
        await fetchAnimes();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    hookState.markReady();
  }

  Future<void> fetchAnimes() async {
    if (!mounted) return;

    setState(() {
      _cache.resolving(null);
    });

    try {
      _cache.resolve(
        await AniListRecommendations.getRecommended(
          0,
          perPage: 14,
          onList: false,
        ),
      );
    } catch (err, stack) {
      _cache.fail(null, ErrorInfo(err, stack));
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getMediaId(
    final AniListMedia media,
    final StateSetter setState,
  ) async {
    if (!mounted) return;

    setState(() {
      mediaCache[media.id]!.resolving(null);
    });

    try {
      final AniListUserInfo user = await AniListUserInfo.getUserInfo();
      final AniListMediaList? fullMedia =
          await AniListMediaList.tryGetFromMediaId(media.id, user.id);

      if (mounted) {
        setState(() {
          mediaCache[media.id]!.resolve(
            fullMedia ??
                AniListMediaList.partial(
                  userId: user.id,
                  media: media,
                ),
          );
        });
      }
    } catch (err, stack) {
      if (mounted) {
        setState(() {
          mediaCache[media.id]!.fail(null, ErrorInfo(err, stack));
        });
      }
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
          ReactiveStateBuilder(
            state: _cache.state,
            onResolving: (final BuildContext context) => SizedBox(
              height: remToPx(8),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            onResolved: (final BuildContext context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: UiUtils.getGridded(
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
                              if (mediaCache[x.id]?.state.hasResolved ??
                                  false) {
                                return mediaCache[x.id]!
                                    .value!
                                    .getDetailedPage(context);
                              }

                              if (mediaCache[x.id] == null) {
                                mediaCache[x.id] = StatefulValueHolderWithError<
                                    AniListMediaList?>(null);

                                getMediaId(x, setState);
                              }

                              if (mediaCache[x.id]?.state.hasFailed ?? false) {
                                return Scaffold(
                                  appBar: AppBar(
                                    actions: <Widget>[
                                      IconButton(
                                        onPressed: () {
                                          if (mounted) {
                                            getMediaId(x, setState);
                                          }
                                        },
                                        icon: const Icon(Icons.refresh),
                                        tooltip: Translator.t.refetch(),
                                      ),
                                    ],
                                  ),
                                  body: Center(
                                    child: KawaiiErrorWidget.fromErrorInfo(
                                      message:
                                          Translator.t.somethingWentWrong(),
                                      error: mediaCache[x.id]!.error,
                                    ),
                                  ),
                                );
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
                                          child: FallbackableNetworkImage(
                                            url: x.coverImageExtraLarge,
                                            placeholder: Image.asset(
                                              Assets
                                                  .placeholderImageFromContext(
                                                context,
                                              ),
                                            ),
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
                                                text:
                                                    '\n${x.titleUserPreferred}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
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
              ),
            ),
            onFailed: (final BuildContext context) => Center(
              child: KawaiiErrorWidget.fromErrorInfo(
                message: Translator.t.failedToGetResults(),
                error: _cache.error,
                actions: <InlineSpan>[
                  KawaiiErrorWidget.buildActionButton(
                    context: context,
                    icon: const Icon(Icons.refresh),
                    child: Text(Translator.t.refetch()),
                    color: Theme.of(context).primaryColor,
                    onTap: fetchAnimes,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}
