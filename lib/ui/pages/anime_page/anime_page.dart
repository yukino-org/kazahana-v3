import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:utilx/utilities/languages.dart';
import './info_page.dart';
import './shared_props.dart';
import './watch_page.dart';
import '../../../config/defaults.dart';
import '../../../modules/database/database.dart';
import '../../../modules/extensions/extensions.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/state/hooks.dart';
import '../../../modules/state/stateful_holder.dart';
import '../../../modules/translator/translator.dart';
import '../../../modules/utils/error.dart';
import '../../components/error_widget.dart';
import '../../components/placeholder_appbar.dart';
import '../../components/reactive_state_builder.dart';
import '../../router.dart';

class PageArguments {
  PageArguments({
    required final this.src,
    required final this.plugin,
  });

  factory PageArguments.fromJson(final Map<String, String> json) {
    if (json['src'] == null) {
      throw ArgumentError("Got null value for 'src'");
    }
    if (json['plugin'] == null) {
      throw ArgumentError("Got null value for 'plugin'");
    }

    return PageArguments(src: json['src']!, plugin: json['plugin']!);
  }

  String src;
  String plugin;

  Map<String, String> toJson() => <String, String>{
        'src': src,
        'plugin': plugin,
      };
}

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> with HooksMixin {
  late final SharedProps props;
  late final PageArguments args;
  late final PageController pageController;

  final StatefulValueHolder<ErrorInfo?> infoState =
      StatefulValueHolder<ErrorInfo?>(null);

  @override
  void initState() {
    super.initState();

    pageController = PageController(
      initialPage: Pages.home.index,
    );

    props = SharedProps(
      setEpisode: (
        final int? index,
      ) {
        if (mounted) {
          setState(() {
            props.currentEpisodeIndex = index;
            props.episode =
                index != null ? props.info!.sortedEpisodes[index] : null;
          });
        }
      },
      goToPage: (final Pages page) async {
        if (pageController.hasClients) {
          await pageController.animateToPage(
            page.index,
            duration: Defaults.animationsNormal,
            curve: Curves.easeInOut,
          );
        }
      },
    );

    onReady(() async {
      args = PageArguments.fromJson(
        ParsedRouteInfo.fromSettings(ModalRoute.of(context)!.settings).params,
      );

      props.extractor = ExtensionsManager.animes[args.plugin];
      if (props.extractor != null) {
        await getInfo();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    hookState.markReady();
  }

  @override
  void dispose() {
    pageController.dispose();

    super.dispose();
  }

  Future<void> getInfo({
    final bool removeCache = false,
  }) async {
    try {
      infoState.resolving(null);

      final int nowMs = DateTime.now().millisecondsSinceEpoch;
      final String cacheKey = 'anime-${props.extractor!.id}-${args.src}';

      if (removeCache) {
        CacheBox.delete(cacheKey);
      }

      final CacheSchema? cachedAnime =
          removeCache ? null : CacheBox.get(cacheKey);

      if (cachedAnime != null &&
          nowMs - cachedAnime.cachedTime <
              Defaults.cachedAnimeInfoExpireTime.inMilliseconds) {
        try {
          if (mounted) {
            setState(() {
              props.info = AnimeInfo.fromJson(
                cachedAnime.value as Map<dynamic, dynamic>,
              );
              infoState.resolve(null);
            });
          }

          return;
        } catch (_) {}
      }

      props.info = await props.extractor!.getInfo(
        args.src,
        props.locale?.name ?? props.extractor!.defaultLocale,
      );

      await CacheBox.saveKV(cacheKey, props.info!.toJson(), nowMs);

      if (mounted) {
        setState(() {
          infoState.resolve(null);
        });
      }
    } catch (err, stack) {
      infoState.fail(ErrorInfo(err, stack));
    }
  }

  @override
  Widget build(final BuildContext context) => WillPopScope(
        child: SafeArea(
          child: ReactiveStateBuilder(
            state: infoState.state,
            onResolving: (final BuildContext context) => Scaffold(
              appBar: const PlaceholderAppBar(),
              body: Center(
                child: props.extractor == null
                    ? KawaiiErrorWidget(
                        message: Translator.t.unknownExtension(args.plugin),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
            onResolved: (final BuildContext context) => PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                InfoPage(
                  props: props,
                  refresh: () async {
                    setState(() {
                      props.info = null;
                    });

                    await getInfo(removeCache: true);
                  },
                  changeLanguage: (final LanguageCodes lang) async {
                    setState(() {
                      props.locale = lang;
                      props.info = null;
                    });

                    await getInfo(removeCache: true);
                  },
                ),
                if (props.episode != null)
                  WatchPage(
                    key: ValueKey<String>(
                      'Episode-${props.currentEpisodeIndex}',
                    ),
                    props: props,
                    pop: () async {
                      await props.goToPage(Pages.home);
                      props.setEpisode(null);
                    },
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
            onFailed: (final BuildContext context) => Scaffold(
              appBar: const PlaceholderAppBar(),
              body: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: remToPx(1.5),
                ),
                child: Center(
                  child: KawaiiErrorWidget.fromErrorInfo(
                    message: Translator.t.failedToGetResults(),
                    error: infoState.value,
                  ),
                ),
              ),
            ),
          ),
        ),
        onWillPop: () async {
          if (props.info != null &&
              pageController.page?.toInt() != Pages.home.index) {
            await props.goToPage(Pages.home);
            props.setEpisode(null);
            return false;
          }

          Navigator.of(context).pop();
          return true;
        },
      );
}
