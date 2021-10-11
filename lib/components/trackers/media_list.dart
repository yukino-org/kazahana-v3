import 'package:animations/animations.dart';
import 'package:extensions/extensions.dart' as extensions;
import 'package:flutter/material.dart';
import '../../../../plugins/helpers/stateful_holder.dart';
import '../../../../plugins/helpers/ui.dart';
import '../../../../plugins/translator/translator.dart';

class MediaList extends StatefulWidget {
  const MediaList({
    required final this.type,
    required final this.status,
    required final this.getMediaList,
    required final this.getItemCard,
    required final this.getItemPage,
    final this.maybeRefresh,
    final Key? key,
  }) : super(key: key);

  final extensions.ExtensionType type;
  final dynamic status;
  final Future<List<dynamic>> Function(int page) getMediaList;
  final Widget Function(BuildContext, dynamic) getItemCard;
  final Widget Function(BuildContext, dynamic) getItemPage;
  final void Function(dynamic)? maybeRefresh;

  @override
  _MediaListState createState() => _MediaListState();
}

class _MediaListState extends State<MediaList> with DidLoadStater {
  List<dynamic>? mediaList;
  int page = 0;

  final Duration animationDuration = const Duration(milliseconds: 300);
  final Widget loader = const Center(
    child: CircularProgressIndicator(),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    doLoadStateIfHasnt();
  }

  @override
  Future<void> load() async {
    final List<dynamic> _mediaList = await widget.getMediaList(page);

    if (mounted) {
      setState(() {
        mediaList = _mediaList;
      });
    }
  }

  @override
  Widget build(final BuildContext context) => ListView(
        children: <Widget>[
          if (mediaList != null) ...<Widget>[
            if (mediaList!.isEmpty) ...<Widget>[
              SizedBox(
                height: remToPx(2),
              ),
              Center(
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
              ),
              SizedBox(
                height: remToPx(2),
              ),
            ] else ...<Widget>[
              ...getGridded(
                MediaQuery.of(context).size.width.toInt(),
                mediaList!
                    .asMap()
                    .map(
                      (
                        final int k,
                        final dynamic x,
                      ) =>
                          MapEntry<int, Widget>(
                        k,
                        OpenContainer(
                          transitionType: ContainerTransitionType.fadeThrough,
                          openColor: Theme.of(context).scaffoldBackgroundColor,
                          closedColor: Colors.transparent,
                          closedElevation: 0,
                          transitionDuration: animationDuration,
                          onClosed: (final dynamic result) {
                            setState(() {});
                          },
                          openBuilder: (
                            final BuildContext context,
                            final VoidCallback cb,
                          ) =>
                              widget.getItemPage(context, x),
                          closedBuilder: (
                            final BuildContext context,
                            final VoidCallback cb,
                          ) =>
                              MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: widget.getItemCard(context, x),
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
              SizedBox(
                height: remToPx(1.5),
              ),
            ]
          ] else ...<Widget>[
            SizedBox(
              height: remToPx(3),
            ),
            loader,
            SizedBox(
              height: remToPx(3),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                splashRadius: remToPx(1),
                onPressed: mediaList != null && page > 0
                    ? () {
                        setState(() {
                          page = page - 1;
                          mediaList = null;
                        });

                        load();
                      }
                    : null,
                icon: const Icon(Icons.arrow_back),
              ),
              SizedBox(
                width: remToPx(0.8),
              ),
              Text('${Translator.t.page()} ${page + 1}'),
              SizedBox(
                width: remToPx(0.8),
              ),
              IconButton(
                splashRadius: remToPx(1),
                onPressed: mediaList != null && mediaList!.isNotEmpty
                    ? () {
                        setState(() {
                          page = page + 1;
                          mediaList = null;
                        });

                        load();
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ],
      );
}
