import 'package:flutter/material.dart';
import './home_page.dart';
import '../../core/provisions/model.dart' as provisions;
import '../../core/provisions/myanimelist/home.dart' as myanimelist;
import '../../core/provisions/myanimelist/utils.dart' as myanimelist;
import '../../core/trackers/myanimelist/myanimelist.dart' as myanimelist;
import '../../plugins/helpers/stateful_holder.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/state.dart';
import '../../plugins/translator/translator.dart';

final StatefulHolder<myanimelist.HomeResult?> _cache =
    StatefulHolder<myanimelist.HomeResult?>(null);

final bool _useHoverTitle = AppState.isDesktop;

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> with DidLoadStater {
  final Duration animationDuration = const Duration(milliseconds: 300);
  final Duration fastAnimationDuration = const Duration(milliseconds: 150);

  int? seasonAnimeHoverIndex;
  int? recentlyUpdatedHoverIndex;
  final Map<int, StatefulHolder<myanimelist.AnimeListEntity?>> mediaCache =
      <int, StatefulHolder<myanimelist.AnimeListEntity?>>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    doLoadStateIfHasnt();
  }

  @override
  Future<void> load() async {
    _cache.resolve(await myanimelist.extractHome());

    if (mounted) {
      setState(() {});
    }
  }

  Widget buildOpenBuilder(final provisions.Entity x) => StatefulBuilder(
        builder: (
          final BuildContext context,
          final StateSetter setState,
        ) {
          final int nodeId = myanimelist.idFromURL(x.url)!;

          if (mediaCache[nodeId]?.hasResolved ?? false) {
            return mediaCache[nodeId]!.value!.getDetailedPage(context);
          }

          if (mediaCache[nodeId] == null) {
            mediaCache[nodeId] =
                StatefulHolder<myanimelist.AnimeListEntity?>(null);

            myanimelist.AnimeListEntity.getFromNodeId(
              nodeId,
            ).then((final myanimelist.AnimeListEntity m) {
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
            HorizontalEntityList(
              animationDuration: animationDuration,
              fastAnimationDuration: fastAnimationDuration,
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
              ) {
                final provisions.Entity x = _cache.value!.seasonEntities[i];
                return buildOpenBuilder(x);
              },
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
            HorizontalEntityList(
              animationDuration: animationDuration,
              fastAnimationDuration: fastAnimationDuration,
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
              ) {
                final provisions.Entity x = _cache.value!.recentlyUpdated[i];
                return buildOpenBuilder(x);
              },
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
