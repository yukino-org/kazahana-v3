import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import '../../../config/defaults.dart';
import '../../../modules/app/state.dart';
import '../../../modules/helpers/assets.dart';
import '../../../modules/helpers/stateful_holder.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/trackers/myanimelist/myanimelist.dart';
import '../../../modules/translator/translator.dart';
import '../../components/network_image_fallback.dart';

final StatefulHolder<MyAnimeListHome?> _cache =
    StatefulHolder<MyAnimeListHome?>(null);

final bool _useHoverTitle = AppState.isDesktop;

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> with DidLoadStater {
  int? seasonAnimeHoverIndex;
  int? recentlyUpdatedHoverIndex;
  final Map<int, StatefulHolder<MyAnimeListAnimeList?>> mediaCache =
      <int, StatefulHolder<MyAnimeListAnimeList?>>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    doLoadStateIfHasnt();
  }

  @override
  Future<void> load() async {
    _cache.resolve(await MyAnimeListHome.extractHome());

    if (mounted) {
      setState(() {});
    }
  }

  Widget buildOpenBuilder(final MyAnimeListHomeContent x) => StatefulBuilder(
        builder: (
          final BuildContext context,
          final StateSetter setState,
        ) {
          final int nodeId = x.id;

          if (mediaCache[nodeId]?.hasResolved ?? false) {
            return mediaCache[nodeId]!.value!.getDetailedPage(context);
          }

          if (mediaCache[nodeId] == null) {
            mediaCache[nodeId] = StatefulHolder<MyAnimeListAnimeList?>(null);

            MyAnimeListAnimeList.getFromNodeId(
              nodeId,
            ).then((final MyAnimeListAnimeList m) {
              if (mounted) {
                setState(() {
                  mediaCache[nodeId]!.resolve(m);
                });
              }
            });
          }

          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );

  @override
  Widget build(final BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _cache.hasResolved && AppState.settings.current.locale == 'en'
                ? _cache.value!.seasonName
                : Translator.t.seasonalAnimes(),
            style: Theme.of(context).textTheme.headline5?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (_cache.hasResolved) ...<Widget>[
            SizedBox(
              height: remToPx(0.3),
            ),
            _HorizontalEntityList(
              entities: _cache.value!.seasonEntities,
              active: (final int i) =>
                  !_useHoverTitle || seasonAnimeHoverIndex == i,
              onHover: (final int i, final bool hovered) {
                if (_useHoverTitle) {
                  setState(() {
                    seasonAnimeHoverIndex = hovered ? i : null;
                  });
                }
              },
              onTap: (final int i, final VoidCallback openContainer) {
                openContainer();
              },
              openBuilder: (
                final int i,
                final BuildContext context,
              ) =>
                  buildOpenBuilder(_cache.value!.seasonEntities[i]),
            ),
            SizedBox(
              height: remToPx(1.5),
            ),
            Text(
              Translator.t.recentlyUpdated(),
              style: Theme.of(context).textTheme.headline5?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(
              height: remToPx(0.3),
            ),
            _HorizontalEntityList(
              entities: _cache.value!.recentlyUpdated,
              active: (final int i) =>
                  !_useHoverTitle || recentlyUpdatedHoverIndex == i,
              onHover: (final int i, final bool hovered) {
                if (_useHoverTitle) {
                  setState(() {
                    recentlyUpdatedHoverIndex = hovered ? i : null;
                  });
                }
              },
              onTap: (final int i, final VoidCallback openContainer) {
                openContainer();
              },
              openBuilder: (
                final int i,
                final BuildContext context,
              ) =>
                  buildOpenBuilder(_cache.value!.recentlyUpdated[i]),
            ),
          ] else
            SizedBox(
              height: remToPx(8),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      );
}

class _HorizontalEntityList extends StatelessWidget {
  const _HorizontalEntityList({
    required final this.entities,
    required final this.onHover,
    required final this.onTap,
    required final this.active,
    required final this.openBuilder,
    final Key? key,
  }) : super(key: key);

  final List<MyAnimeListHomeContent> entities;
  final void Function(int, bool) onHover;
  final void Function(int, VoidCallback) onTap;
  final bool Function(int) active;
  final Widget Function(int, BuildContext) openBuilder;

  @override
  Widget build(final BuildContext context) => SizedBox(
        height: remToPx(11),
        child: ScrollConfiguration(
          behavior: MiceScrollBehavior(),
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: entities
                .asMap()
                .map(
                  (final int i, final MyAnimeListHomeContent x) =>
                      MapEntry<int, Widget>(
                    i,
                    Padding(
                      padding: EdgeInsets.only(
                        left: i != 0 ? remToPx(0.2) : 0,
                        right: i != entities.length - 1 ? remToPx(0.2) : 0,
                      ),
                      child: OpenContainer(
                        transitionType: ContainerTransitionType.fadeThrough,
                        openColor: Theme.of(context).scaffoldBackgroundColor,
                        closedColor: Colors.transparent,
                        closedElevation: 0,
                        tappable: false,
                        closedBuilder: (
                          final BuildContext context,
                          final VoidCallback openContainer,
                        ) =>
                            ClipRRect(
                          borderRadius: BorderRadius.circular(remToPx(0.3)),
                          child: SizedBox(
                            width: remToPx(8),
                            child: Stack(
                              children: <Widget>[
                                Positioned.fill(
                                  child: FallbackableNetworkImage(
                                    url: x.thumbnail,
                                    placeholder: Image.asset(
                                      Assets.placeholderImage(
                                        dark: UiUtils.isDarkContext(
                                          context,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: AnimatedOpacity(
                                    duration: Defaults.animationsSlower,
                                    opacity: active(i) ? 1 : 0,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: <Color>[
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: AnimatedSlide(
                                    curve: Curves.easeInOut,
                                    duration: Defaults.animationsFast,
                                    offset: active(i)
                                        ? Offset.zero
                                        : const Offset(0, 1),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: remToPx(0.4),
                                        vertical: remToPx(0.2),
                                      ),
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          children: <InlineSpan>[
                                            TextSpan(
                                              text: x.title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            TextSpan(
                                              text: '\n${x.type.type}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                  ),
                                            ),
                                            if (x.latest != null)
                                              TextSpan(
                                                text:
                                                    ' | ${Translator.t.episode()} ${x.latest}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                    ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: InkWell(
                                      onTap: () => onTap(i, openContainer),
                                      onHover: (final bool hovered) =>
                                          onHover(i, hovered),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        openBuilder: (
                          final BuildContext context,
                          final VoidCallback cb,
                        ) =>
                            openBuilder(i, context),
                      ),
                    ),
                  ),
                )
                .values
                .toList(),
          ),
        ),
      );
}
