import 'dart:ui';
import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:utilx/utilities/utils.dart';
import '../../../config/defaults.dart';
import '../../../modules/helpers/assets.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/trackers/provider.dart';
import '../../../modules/translator/translator.dart';
import '../../pages/search_page/controller.dart';
import '../../router.dart';

typedef OnEditCallback = void Function(DetailedInfo);

class DetailedItem extends StatefulWidget {
  const DetailedItem({
    required final this.item,
    required final this.onEdit,
    final this.onPlay,
    final this.showBodyLoading = false,
    final this.readonly = false,
    final Key? key,
  }) : super(key: key);

  final DetailedInfo item;
  final Widget Function(OnEditCallback) onEdit;
  final void Function()? onPlay;
  final bool showBodyLoading;
  final bool readonly;

  @override
  _DetailedItemState createState() => _DetailedItemState();
}

class _DetailedItemState extends State<DetailedItem> {
  final ValueNotifier<bool> appBarDetails = ValueNotifier<bool>(false);

  late DetailedInfo item = widget.item;

  @override
  void dispose() {
    appBarDetails.dispose();

    super.dispose();
  }

  void pushToSearchPage() {
    Navigator.of(context).pushNamed(
      ParsedRouteInfo(
        RouteNames.search,
        SearchPageArguments(
          terms: item.title,
          pluginType: item.type,
          autoSearch: true,
        ).toJson(),
      ).toString(),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isLargest = size.width > ResponsiveSizes.lg;
    final bool isLarge = size.width > ResponsiveSizes.md;

    final double heroHeight = remToPx(20);
    final double bannerHeight = isLargest ? 0 : (20 / 100) * size.height;

    final bool largeAndDark = isLargest && !UiUtils.isDarkContext(context);
    final double playBtnTextSize = isLargest
        ? Theme.of(context).textTheme.headline6!.fontSize! - remToPx(0.2)
        : Theme.of(context).textTheme.bodyText1!.fontSize!;
    final Color playBtnTextColor = largeAndDark ? Colors.black : Colors.white;
    final Widget playBtn = Material(
      type: MaterialType.transparency,
      elevation: 5,
      color: Colors.white,
      child: Ink(
        decoration: BoxDecoration(
          color: largeAndDark ? Colors.white : Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(remToPx(0.2)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(remToPx(0.2)),
          onTap: widget.onPlay ?? pushToSearchPage,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: remToPx(0.5),
              vertical: remToPx(0.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.play_arrow_rounded,
                  color: playBtnTextColor,
                  size: playBtnTextSize + remToPx(0.1),
                ),
                SizedBox(
                  width: remToPx(0.3),
                ),
                Text(
                  item.type == ExtensionType.anime
                      ? Translator.t.play()
                      : Translator.t.read(),
                  style: TextStyle(
                    fontSize: playBtnTextSize,
                    color: playBtnTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (final ScrollNotification notification) {
        if (notification is UserScrollNotification &&
            notification.metrics.axis == Axis.vertical) {
          appBarDetails.value = notification.metrics.pixels > heroHeight;
        }

        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ValueListenableBuilder<bool>(
            valueListenable: appBarDetails,
            builder: (
              final BuildContext context,
              final bool appBarDetails,
              final Widget? child,
            ) =>
                AnimatedSwitcher(
              duration: Defaults.animationsSlower,
              child: appBarDetails
                  ? AppBar(
                      key: UniqueKey(),
                      backgroundColor:
                          Theme.of(context).appBarTheme.backgroundColor,
                      title: Text(item.title),
                      actions: <Widget>[
                        IconButton(
                          onPressed: pushToSearchPage,
                          icon: const Icon(Icons.play_arrow),
                        ),
                      ],
                    )
                  : AppBar(
                      key: UniqueKey(),
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                    ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: heroHeight,
                child: Stack(
                  children: <Widget>[
                    if (item.banner != null || item.thumbnail != null)
                      Positioned.fill(
                        bottom: bannerHeight,
                        child: ClipRRect(
                          child: item.banner != null
                              ? Image.network(
                                  item.banner!,
                                  fit: BoxFit.cover,
                                )
                              : ImageFiltered(
                                  imageFilter:
                                      ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                                  child: Image.network(
                                    item.thumbnail!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                    Positioned.fill(
                      bottom: bannerHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Colors.transparent,
                              Theme.of(context)
                                  .scaffoldBackgroundColor
                                  .withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: isLargest
                            ? EdgeInsets.symmetric(
                                horizontal: remToPx(5),
                                vertical: remToPx(1.5),
                              )
                            : EdgeInsets.zero,
                        child: Row(
                          mainAxisAlignment: isLargest
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(remToPx(0.25)),
                              child: Image(
                                image: item.thumbnail != null
                                    ? NetworkImage(item.thumbnail!)
                                    : AssetImage(
                                        Assets.placeholderImageFromContext(
                                          context,
                                        ),
                                      ) as ImageProvider<Object>,
                                width: remToPx(9),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            if (isLargest) ...<Widget>[
                              SizedBox(
                                width: remToPx(2),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      item.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        shadows: <Shadow>[
                                          Shadow(
                                            blurRadius: remToPx(1),
                                            color:
                                                Colors.black.withOpacity(0.3),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: remToPx(0.1),
                                    ),
                                    Text(
                                      StringUtils.capitalize(
                                        item.type.type,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          ?.copyWith(
                                        color: UiUtils.isDarkContext(context)
                                            ? Theme.of(context).primaryColor
                                            : Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.bold,
                                        shadows: <Shadow>[
                                          if (UiUtils.isDarkContext(context))
                                            Shadow(
                                              blurRadius: remToPx(1),
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                            ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: remToPx(0.8),
                                    ),
                                    playBtn,
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: remToPx(isLarge ? 3 : 1.25),
                  right: remToPx(isLarge ? 3 : 1.25),
                  top: remToPx(2),
                  bottom: remToPx(isLarge ? 2 : 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (!isLargest) ...<Widget>[
                      Text(
                        StringUtils.capitalize(
                          item.type.type,
                        ),
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.headline5?.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodyText1?.color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(
                        height: remToPx(0.3),
                      ),
                      playBtn,
                      SizedBox(
                        height: remToPx(1),
                      ),
                    ],
                    if (widget.showBodyLoading) ...<Widget>[
                      SizedBox(
                        height: isLarge ? remToPx(4) : remToPx(1),
                      ),
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ] else ...<Widget>[
                      if (item.description != null) ...<Widget>[
                        MarkdownBody(
                          data: item.description!,
                        ),
                        SizedBox(
                          height: remToPx(1),
                        ),
                      ],
                      if (!widget.readonly) ...<Widget>[
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.caption,
                            children: <InlineSpan>[
                              TextSpan(
                                text: Translator.t.progress(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (item.status != null)
                                TextSpan(
                                  text: '  (${item.status})',
                                ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: remToPx(0.5),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyText1,
                                children: <InlineSpan>[
                                  TextSpan(
                                    text: item.progress.progress
                                        .toString()
                                        .padLeft(2, '0'),
                                  ),
                                  if (item.progress.volumes?.progress != null)
                                    TextSpan(
                                      text:
                                          ' (${item.progress.volumes!.progress.toString().padLeft(2, '0')} ${Translator.t.vols()})',
                                    ),
                                  if (item.progress.startedAt != null)
                                    TextSpan(
                                      text:
                                          '${isLarge ? '  ' : '\n'}(${item.progress.startedAt.toString().split(' ').first})',
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                ],
                              ),
                            ),
                            if (item.progress.total != null)
                              Text(
                                '${((item.progress.progress / item.progress.total!) * 100).toInt()}%',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyText1,
                                children: <InlineSpan>[
                                  if (isLarge &&
                                      item.progress.completedAt != null)
                                    TextSpan(
                                      text:
                                          '(${item.progress.completedAt.toString().split(' ').first})  ',
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                  TextSpan(
                                    text: item.progress.total
                                            ?.toString()
                                            .padLeft(2, '0') ??
                                        '?',
                                  ),
                                  if (item.progress.volumes != null)
                                    TextSpan(
                                      text:
                                          ' (${item.progress.volumes!.progress.toString().padLeft(2, '0')} ${Translator.t.vols()})',
                                    ),
                                  if (!isLarge &&
                                      item.progress.completedAt != null)
                                    TextSpan(
                                      text:
                                          '\n(${item.progress.completedAt.toString().split(' ').first})',
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: remToPx(0.5),
                        ),
                        LinearProgressIndicator(
                          backgroundColor: item.progress.total != null
                              ? Theme.of(context).primaryColor.withOpacity(0.25)
                              : Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.color
                                  ?.withOpacity(0.1),
                          value: item.progress.total != null
                              ? item.progress.progress / item.progress.total!
                              : 0,
                        ),
                        SizedBox(
                          height: remToPx(0.5),
                        ),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyText1,
                            children: <InlineSpan>[
                              if (item.repeated != null) ...<InlineSpan>[
                                TextSpan(
                                  text: '${Translator.t.repeat()}: ',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .caption
                                        ?.color,
                                  ),
                                ),
                                TextSpan(
                                  text: '${item.repeated!.toString()}\n',
                                ),
                              ],
                              TextSpan(
                                text: '${Translator.t.score()}: ',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .caption
                                      ?.color,
                                ),
                              ),
                              TextSpan(
                                text: '${item.score ?? '?'} / 100',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: remToPx(1),
                        ),
                      ],
                      Text(
                        Translator.t.characters(),
                        style: Theme.of(context).textTheme.headline6?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(
                        height: remToPx(0.5),
                      ),
                      ...UiUtils.getGridded(
                        size.width.toInt(),
                        item.characters
                            .map(
                              (final Character x) => Card(
                                child: Padding(
                                  padding: EdgeInsets.all(remToPx(0.5)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        width: remToPx(3),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            remToPx(0.25),
                                          ),
                                          child: Image.network(
                                            x.image,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: remToPx(0.75)),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              x.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .headline6
                                                    ?.fontSize,
                                              ),
                                            ),
                                            Text(
                                              StringUtils.capitalize(x.role),
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    ?.fontSize,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        breakpoint: <int, int>{
                          ResponsiveSizes.md: 2,
                        },
                      ),
                      SizedBox(
                        height: remToPx(3),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: widget.showBodyLoading || widget.readonly
            ? null
            : FloatingActionButton(
                onPressed: () async {
                  await showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: MaterialLocalizations.of(context)
                        .modalBarrierDismissLabel,
                    pageBuilder: (
                      final BuildContext context,
                      final Animation<double> a1,
                      final Animation<double> a2,
                    ) =>
                        SafeArea(
                      child: widget.onEdit((final DetailedInfo info) {
                        if (!mounted) return;
                        setState(() {
                          item = info;
                        });
                      }),
                    ),
                  );

                  if (!mounted) return;
                  setState(() {});
                },
                tooltip: Translator.t.edit(),
                child: const Icon(Icons.edit),
              ),
      ),
    );
  }
}
