import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import './edit_modal.dart';
import '../../../core/models/page_args/search_page.dart' as search_page;
import '../../../core/trackers/anilist/anilist.dart' as anilist;
import '../../../plugins/helpers/ui.dart';
import '../../../plugins/helpers/utils/string.dart';
import '../../../plugins/router.dart';
import '../../../plugins/translator/translator.dart';

class DetailedItem extends StatefulWidget {
  const DetailedItem({
    required final this.media,
    final this.onPlay,
    final Key? key,
  }) : super(key: key);

  final anilist.MediaList media;
  final void Function()? onPlay;

  @override
  _DetailedItemState createState() => _DetailedItemState();
}

class _DetailedItemState extends State<DetailedItem> {
  final ValueNotifier<bool> appBarDetails = ValueNotifier<bool>(false);
  final Duration animationDuration = const Duration(milliseconds: 300);

  late anilist.MediaList modifiedMedia = widget.media;

  @override
  void dispose() {
    appBarDetails.dispose();

    super.dispose();
  }

  void pushToSearchPage() {
    Navigator.of(context).pushNamed(
      ParsedRouteInfo(
        RouteNames.search,
        search_page.PageArguments(
          terms: widget.media.media.titleUserPreferred,
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

    final int? totalProgress =
        widget.media.media.episodes ?? widget.media.media.chapters;

    final bool largeAndDark = isLargest && !isDarkContext(context);
    final double playBtnTextSize = isLargest
        ? Theme.of(context).textTheme.headline6!.fontSize! - remToPx(0.1)
        : Theme.of(context).textTheme.bodyText1!.fontSize!;
    final Color playBtnTextColor = largeAndDark ? Colors.black : Colors.white;
    final Widget playBtn = TextButton.icon(
      icon: Icon(
        Icons.play_arrow,
        color: playBtnTextColor,
        size: playBtnTextSize + remToPx(0.2),
      ),
      label: Text(
        widget.media.media.type == anilist.MediaType.anime
            ? Translator.t.play()
            : Translator.t.read(),
        style: TextStyle(
          fontSize: playBtnTextSize,
          color: playBtnTextColor,
        ),
      ),
      style: TextButton.styleFrom(
        elevation: 5,
        backgroundColor:
            largeAndDark ? Colors.white : Theme.of(context).primaryColor,
        padding: EdgeInsets.symmetric(
          horizontal: remToPx(0.5),
          vertical: remToPx(0.5),
        ),
      ),
      onPressed: widget.onPlay ?? pushToSearchPage,
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
              duration: animationDuration,
              child: appBarDetails
                  ? AppBar(
                      key: UniqueKey(),
                      backgroundColor:
                          Theme.of(context).appBarTheme.backgroundColor,
                      title: Text(widget.media.media.titleUserPreferred),
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
                    if (widget.media.media.bannerImage != null)
                      Positioned.fill(
                        bottom: bannerHeight,
                        child: Image.network(
                          widget.media.media.bannerImage!,
                          fit: BoxFit.cover,
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
                          crossAxisAlignment:
                              widget.media.media.bannerImage != null
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.center,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(remToPx(0.25)),
                              child: Image.network(
                                widget.media.media.coverImageExtraLarge,
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
                                      widget.media.media.titleUserPreferred,
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
                                    ),
                                    Text(
                                      StringUtils.capitalize(
                                        widget.media.media.type.type,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          ?.copyWith(
                                        color: isDarkContext(context)
                                            ? Theme.of(context).primaryColor
                                            : Colors.white.withOpacity(0.6),
                                        fontWeight: FontWeight.bold,
                                        shadows: <Shadow>[
                                          if (isDarkContext(context))
                                            Shadow(
                                              blurRadius: remToPx(1),
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                            ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: remToPx(1),
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
                  top: remToPx(widget.media.media.bannerImage != null ? 2 : 0),
                  bottom: remToPx(isLarge ? 2 : 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (!isLargest) ...<Widget>[
                      Text(
                        StringUtils.capitalize(
                          widget.media.media.type.type,
                        ),
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        widget.media.media.titleUserPreferred,
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
                    if (widget.media.media.description != null) ...<Widget>[
                      MarkdownBody(
                        data: widget.media.media.description!
                            .replaceAll(RegExp('<br[ /]*>'), '\n'),
                      ),
                      SizedBox(
                        height: remToPx(1),
                      ),
                    ],
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.caption,
                        children: <InlineSpan>[
                          TextSpan(
                            text: Translator.t.progress(),
                            style:
                                Theme.of(context).textTheme.headline6?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          TextSpan(
                            text:
                                '  (${StringUtils.capitalize(widget.media.status.status)})',
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
                                text: widget.media.progress
                                    .toString()
                                    .padLeft(2, '0'),
                              ),
                              if (widget.media.progressVolumes != null)
                                TextSpan(
                                  text:
                                      ' (${widget.media.progressVolumes.toString().padLeft(2, '0')} ${Translator.t.vols()})',
                                ),
                              if (widget.media.startedAt != null)
                                TextSpan(
                                  text:
                                      '${isLarge ? '  ' : '\n'}(${widget.media.startedAt.toString().split(' ').first})',
                                  style: Theme.of(context).textTheme.caption,
                                ),
                            ],
                          ),
                        ),
                        if (totalProgress != null)
                          Text(
                            '${((widget.media.progress / totalProgress) * 100).toInt()}%',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyText1,
                            children: <InlineSpan>[
                              if (isLarge && widget.media.completedAt != null)
                                TextSpan(
                                  text:
                                      '(${widget.media.completedAt.toString().split(' ').first})  ',
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              TextSpan(
                                text:
                                    totalProgress?.toString().padLeft(2, '0') ??
                                        '?',
                              ),
                              if (widget.media.media.volumes != null)
                                TextSpan(
                                  text:
                                      ' (${widget.media.media.volumes.toString().padLeft(2, '0')} ${Translator.t.vols()})',
                                ),
                              if (!isLarge && widget.media.completedAt != null)
                                TextSpan(
                                  text:
                                      '\n(${widget.media.completedAt.toString().split(' ').first})',
                                  style: Theme.of(context).textTheme.caption,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: remToPx(0.5),
                    ),
                    if (totalProgress != null)
                      LinearProgressIndicator(
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.25),
                        value: widget.media.progress / totalProgress,
                      ),
                    SizedBox(
                      height: remToPx(0.5),
                    ),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyText1,
                        children: <InlineSpan>[
                          TextSpan(
                            text: '${Translator.t.repeat()}: ',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.caption?.color,
                            ),
                          ),
                          TextSpan(
                            text: widget.media.repeat.toString(),
                          ),
                          TextSpan(
                            text: '\n${Translator.t.score()}: ',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.caption?.color,
                            ),
                          ),
                          TextSpan(
                            text: '${widget.media.score} / 100',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: remToPx(1),
                    ),
                    Text(
                      Translator.t.characters(),
                      style: Theme.of(context).textTheme.headline6?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(
                      height: remToPx(0.5),
                    ),
                    ...getGridded(
                      size,
                      widget.media.media.characters
                          .map(
                            (final anilist.Character x) => Card(
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
                                        child: Image.network(x.imageMedium),
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
                                            x.nameUserPreferred,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .headline6
                                                  ?.fontSize,
                                            ),
                                          ),
                                          Text(
                                            StringUtils.capitalize(x.role.role),
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
                      breakpoint: ResponsiveSizes.md,
                    ),
                    SizedBox(
                      height: remToPx(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel:
                  MaterialLocalizations.of(context).modalBarrierDismissLabel,
              pageBuilder: (
                final BuildContext context,
                final Animation<double> a1,
                final Animation<double> a2,
              ) =>
                  EditModal(media: widget.media),
            );
            setState(() {});
          },
          tooltip: Translator.t.edit(),
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }
}
