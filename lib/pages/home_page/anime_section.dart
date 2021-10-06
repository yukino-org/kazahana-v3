import 'package:flutter/material.dart';
import './home_page.dart';
import '../../core/provisions/myanimelist/home.dart' as mal;
import '../../plugins/helpers/stateful_holder.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/translator/translator.dart';

final StatefulHolder<mal.HomeResult?> _cache =
    StatefulHolder<mal.HomeResult?>(null);

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    doLoadStateIfHasnt();
  }

  @override
  Future<void> load() async {
    _cache.resolve(await mal.extractHome());
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(final BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _cache.hasResolved
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
              active: (final int i) => seasonAnimeHoverIndex == i,
              onHover: (final int i, final bool hovered) {
                setState(() {
                  seasonAnimeHoverIndex = hovered ? i : null;
                });
              },
              onTap: (final int i) {
                setState(() {
                  seasonAnimeHoverIndex = i;
                });

                // TODO: push
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
              active: (final int i) => recentlyUpdatedHoverIndex == i,
              onHover: (final int i, final bool hovered) {
                setState(() {
                  recentlyUpdatedHoverIndex = hovered ? i : null;
                });
              },
              onTap: (final int i) {
                setState(() {
                  recentlyUpdatedHoverIndex = i;
                });

                // TODO: push
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
