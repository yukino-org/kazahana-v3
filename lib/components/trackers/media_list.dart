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
    final Key? key,
  }) : super(key: key);

  final extensions.ExtensionType type;
  final dynamic status;
  final Future<List<dynamic>> Function(int page) getMediaList;
  final Widget Function(BuildContext, dynamic) getItemCard;
  final Widget Function(BuildContext, dynamic) getItemPage;

  @override
  _MediaListState createState() => _MediaListState();
}

class _MediaListState extends State<MediaList> with DidLoadStater {
  List<dynamic>? mediaList;

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
    final List<dynamic> _mediaList = await widget.getMediaList(0);

    if (mounted) {
      setState(() {
        mediaList = _mediaList;
      });
    }
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
