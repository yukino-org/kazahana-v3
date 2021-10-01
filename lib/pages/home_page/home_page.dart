import 'package:flutter/material.dart';
import './anilist_section.dart' as anilist_section;
import './anime_section.dart' as anime_section;
import '../../components/network_image_fallback.dart';
import '../../core/provisions/model.dart';
import '../../core/provisions/myanimelist/utils.dart' as mal_utils;
import '../../plugins/helpers/assets.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/translator/translator.dart';

enum Pages {
  anime,
  manga,
}

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  late Pages currentPage;
  final Map<Pages, Widget> stack = <Pages, Widget>{
    Pages.anime: Builder(
      builder: (final BuildContext context) => const anime_section.Page(),
    ),
  };

  @override
  void initState() {
    super.initState();

    currentPage = Pages.values.first;
  }

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: remToPx(1),
            horizontal: remToPx(1.25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Translator.t.home(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: Theme.of(context).textTheme.headline6?.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: remToPx(1),
              ),
              if (anilist_section.enabled()) ...<Widget>[
                const anilist_section.Page(),
                SizedBox(
                  height: remToPx(1),
                ),
              ],
              stack[currentPage]!,
              SizedBox(
                height: remToPx(2),
              ),
            ],
          ),
        ),
      );
}

class HorizontalEntityList extends StatelessWidget {
  const HorizontalEntityList({
    required final this.animationDuration,
    required final this.fastAnimationDuration,
    required final this.entities,
    required final this.onHover,
    required final this.onTap,
    required final this.active,
    final Key? key,
  }) : super(key: key);

  final Duration animationDuration;
  final Duration fastAnimationDuration;
  final List<Entity> entities;
  final void Function(int, bool) onHover;
  final void Function(int) onTap;
  final bool Function(int) active;

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
                  (final int i, final Entity x) => MapEntry<int, Widget>(
                    i,
                    Padding(
                      padding: EdgeInsets.only(
                        left: i != 0 ? remToPx(0.2) : 0,
                        right: i != entities.length - 1 ? remToPx(0.2) : 0,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(remToPx(0.3)),
                        child: SizedBox(
                          width: remToPx(8),
                          child: Stack(
                            children: <Widget>[
                              Positioned.fill(
                                child: FallbackableNetworkImage(
                                  url: mal_utils.tryMaxRes(x.thumbnail),
                                  placeholder: Image.asset(
                                    Assets.placeholderImage(
                                      dark: isDarkContext(
                                        context,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: AnimatedOpacity(
                                  duration: animationDuration,
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
                                  duration: fastAnimationDuration,
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
                                    onTap: () => onTap(i),
                                    onHover: (final bool hovered) =>
                                        onHover(i, hovered),
                                  ),
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
          ),
        ),
      );
}
