import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import './detailed_item.dart';
import '../../../../core/trackers/anilist/anilist.dart' as anilist;
import '../../../../plugins/helpers/ui.dart';
import '../../../../plugins/translator/translator.dart';

class MediaList extends StatefulWidget {
  const MediaList({
    required final this.type,
    required final this.status,
    final Key? key,
  }) : super(key: key);

  final anilist.MediaType type;
  final anilist.MediaListStatus status;

  @override
  _MediaListState createState() => _MediaListState();
}

class _MediaListState extends State<MediaList> {
  List<anilist.MediaList>? mediaList;

  final Duration animationDuration = const Duration(milliseconds: 300);
  final Widget loader = const Center(
    child: CircularProgressIndicator(),
  );

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(Duration.zero, () async {
      final List<anilist.MediaList> _mediaList =
          await anilist.getMediaList(widget.type, widget.status, 0);

      if (mounted) {
        setState(() {
          mediaList = _mediaList;
        });
      }
    });
  }

  @override
  Widget build(final BuildContext context) => mediaList != null
      ? mediaList!.isEmpty
          ? Center(
              child: Text(
                Translator.t.nothingWasFoundHere(),
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyText1
                      ?.color
                      ?.withOpacity(0.7),
                ),
              ),
            )
          : ListView(
              children: getGridded(
                MediaQuery.of(context).size.width.toInt(),
                mediaList!
                    .asMap()
                    .map(
                      (
                        final int k,
                        final anilist.MediaList x,
                      ) =>
                          MapEntry<int, Widget>(
                        k,
                        OpenContainer(
                          transitionType: ContainerTransitionType.fadeThrough,
                          openColor: Theme.of(context).scaffoldBackgroundColor,
                          closedColor: Theme.of(context).cardColor,
                          closedElevation: 0,
                          transitionDuration: animationDuration,
                          onClosed: (final dynamic result) {
                            setState(() {});
                          },
                          openBuilder: (
                            final BuildContext context,
                            final VoidCallback cb,
                          ) =>
                              DetailedItem(
                            media: x,
                          ),
                          closedBuilder: (
                            final BuildContext context,
                            final VoidCallback cb,
                          ) =>
                              MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(remToPx(0.3)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      width: remToPx(4),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          remToPx(0.25),
                                        ),
                                        child: Image.network(
                                          x.media.coverImageMedium,
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
                                            x.media.titleUserPreferred,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: Theme.of(context)
                                                      .textTheme
                                                      .headline6!
                                                      .fontSize! -
                                                  remToPx(0.1),
                                            ),
                                          ),
                                          SizedBox(
                                            height: remToPx(0.1),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              children: <InlineSpan>[
                                                TextSpan(
                                                  text:
                                                      '${Translator.t.progress()}: ${x.progress}',
                                                ),
                                                if (x.startedAt != null)
                                                  TextSpan(
                                                    text:
                                                        ' (${x.startedAt.toString().split(' ').first})',
                                                  ),
                                                TextSpan(
                                                  text:
                                                      ' / ${x.media.episodes ?? x.media.chapters ?? '?'}',
                                                ),
                                                if (x.completedAt != null)
                                                  TextSpan(
                                                    text:
                                                        ' (${x.completedAt.toString().split(' ').first})',
                                                  ),
                                              ],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .values
                    .toList(),
                spacer: SizedBox(
                  width: remToPx(0.4),
                ),
              ),
            )
      : Column(
          children: <Widget>[
            SizedBox(
              height: remToPx(3),
            ),
            loader,
          ],
        );
}
