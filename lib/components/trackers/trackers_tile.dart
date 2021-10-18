import 'package:animations/animations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/models/tracker_provider.dart';
import '../../plugins/helpers/assets.dart';
import '../../plugins/helpers/stateful_holder.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/router.dart';
import '../../plugins/translator/translator.dart';

class TrackersTile extends StatelessWidget {
  const TrackersTile({
    required final this.title,
    required final this.plugin,
    required final this.providers,
    final Key? key,
  }) : super(key: key);

  final String title;
  final String plugin;
  final List<TrackerProvider<BaseProgress>> providers;

  @override
  Widget build(final BuildContext context) => Column(
        children: providers
            .asMap()
            .map(
              (final int i, final TrackerProvider<BaseProgress> x) =>
                  MapEntry<int, Widget>(
                i,
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i != providers.length - 1 ? remToPx(0.4) : 0,
                  ),
                  child: TrackersTileItem(
                    title: title,
                    plugin: plugin,
                    tracker: x,
                  ),
                ),
              ),
            )
            .values
            .toList(),
      );
}

class TrackersTileItem extends StatefulWidget {
  const TrackersTileItem({
    required final this.title,
    required final this.plugin,
    required final this.tracker,
    final Key? key,
  }) : super(key: key);

  final String title;
  final String plugin;
  final TrackerProvider<BaseProgress> tracker;

  @override
  _TrackersTileItemState createState() => _TrackersTileItemState();
}

class _TrackersTileItemState extends State<TrackersTileItem>
    with DidLoadStater {
  StatefulHolder<List<ResolvableTrackerItem>?> searches =
      StatefulHolder<List<ResolvableTrackerItem>?>(null);

  StatefulHolder<ResolvedTrackerItem?> item =
      StatefulHolder<ResolvedTrackerItem?>(null);

  @override
  void initState() {
    super.initState();

    onItemUpdateChangeNotifier.subscribe(_onMediaUpdated);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    doLoadStateIfHasnt();
  }

  @override
  void dispose() {
    onItemUpdateChangeNotifier.unsubscribe(_onMediaUpdated);

    super.dispose();
  }

  @override
  Future<void> load() async {
    if (mounted && widget.tracker.isLoggedIn()) {
      setState(() {
        item.resolving(null);
      });

      ResolvedTrackerItem? computed;
      try {
        computed = await widget.tracker.getComputed(
          widget.title,
          widget.plugin,
        );
      } catch (_) {
        computed = await widget.tracker.getComputed(
          widget.title,
          widget.plugin,
          force: true,
        );
      }

      if (mounted) {
        setState(() {
          item.resolve(computed);
        });
      }
    }
  }

  void _onMediaUpdated(
    final ResolvedTrackerItem unknown, [
    final dynamic data,
  ]) {
    if (item.value != null &&
        widget.tracker.isItemSameKind(item.value!, unknown)) {
      setState(() {
        item.resolve(unknown);
      });
    }
  }

  InlineSpan openSearchTextSpan(final String text) => TextSpan(
        text: text,
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
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
                  SafeArea(
                child: Dialog(
                  child: StatefulBuilder(
                    builder: (
                      final BuildContext context,
                      final StateSetter setState,
                    ) =>
                        SafeArea(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: remToPx(1),
                              bottom: remToPx(2),
                              left: remToPx(1.5),
                              right: remToPx(1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    IconButton(
                                      splashRadius: remToPx(1),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Icon(Icons.arrow_back),
                                      tooltip: Translator.t.back(),
                                    ),
                                    SizedBox(width: remToPx(1)),
                                    Text(
                                      Translator.t.search(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          ?.copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: Translator.t
                                        .searchInPlugin(widget.tracker.name),
                                  ),
                                  onSubmitted: (final String value) async {
                                    setState(() {
                                      searches.resolving(null);
                                    });

                                    final List<ResolvableTrackerItem> results =
                                        await widget.tracker.getComputables(
                                      value,
                                    );

                                    setState(() {
                                      searches.resolve(results);
                                    });
                                  },
                                ),
                                if (searches.hasResolved &&
                                    searches.value!.isNotEmpty) ...<Widget>[
                                  SizedBox(
                                    height: remToPx(1),
                                  ),
                                  ...getGridded(
                                    MediaQuery.of(context).size.width.toInt(),
                                    searches.value!
                                        .map(
                                          (final ResolvableTrackerItem x) =>
                                              Card(
                                            color: Palette.gray[
                                                isDarkContext(context)
                                                    ? 700
                                                    : 200],
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              onTap: () async {
                                                ResolvedTrackerItem? resolved;
                                                try {
                                                  resolved = await widget
                                                      .tracker
                                                      .resolveComputed(
                                                    widget.title,
                                                    widget.plugin,
                                                    x,
                                                  );
                                                } catch (_) {
                                                  resolved = await widget
                                                      .tracker
                                                      .getComputed(
                                                    widget.title,
                                                    widget.plugin,
                                                    force: true,
                                                  );
                                                }

                                                this.setState(() {
                                                  item.resolve(resolved);
                                                });

                                                if (mounted) {
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                  remToPx(0.5),
                                                ),
                                                child: Row(
                                                  children: <Widget>[
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        remToPx(0.25),
                                                      ),
                                                      child: x.image != null
                                                          ? Image.network(
                                                              x.image!,
                                                              height:
                                                                  remToPx(5),
                                                            )
                                                          : Image.asset(
                                                              Assets
                                                                  .placeholderImage(
                                                                dark:
                                                                    isDarkContext(
                                                                  context,
                                                                ),
                                                              ),
                                                              height:
                                                                  remToPx(5),
                                                            ),
                                                    ),
                                                    SizedBox(
                                                      width: remToPx(0.75),
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        x.title,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .headline6
                                                                  ?.fontSize,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ] else if (searches.isResolving) ...<Widget>[
                                  SizedBox(
                                    height: remToPx(3),
                                  ),
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ] else ...<Widget>[
                                  SizedBox(
                                    height: remToPx(2),
                                  ),
                                  Center(
                                    child: Text(
                                      searches.hasResolved
                                          ? Translator.t.noResultsFound()
                                          : searches.isWaiting
                                              ? Translator.t.enterToSearch()
                                              : Translator.t
                                                  .failedToGetResults(),
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .color!
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );

            searches.waiting(null);
          },
        mouseCursor: SystemMouseCursors.click,
        style: Theme.of(context).textTheme.subtitle2?.copyWith(
              color: Colors.red.withOpacity(1),
              fontWeight: FontWeight.bold,
            ),
      );

  @override
  Widget build(final BuildContext context) => Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.tracker.isLoggedIn()
              ? null
              : () {
                  Navigator.of(context).pushNamed(RouteNames.store);
                },
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: remToPx(1),
                backgroundColor: Colors.black,
                child: Image.asset(
                  widget.tracker.image,
                  height: remToPx(1.5),
                ),
              ),
              SizedBox(
                width: remToPx(1),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: widget.tracker.name,
                        style: Theme.of(context).textTheme.headline6?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (item.hasResolved &&
                          item.value != null) ...<InlineSpan>[
                        TextSpan(
                          text: '\n${Translator.t.computedAs()} ',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              ?.copyWith(
                                color:
                                    Theme.of(context).textTheme.caption?.color,
                              ),
                        ),
                        TextSpan(
                          text: item.value!.title,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
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
                                    FadeScaleTransition(
                                  animation: a1,
                                  child: SafeArea(
                                    child: widget.tracker
                                        .getDetailedPage(context, item.value!),
                                  ),
                                ),
                              );
                            },
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              ?.copyWith(
                                color:
                                    Theme.of(context).textTheme.caption?.color,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        openSearchTextSpan(' - ${Translator.t.notThis()}'),
                      ] else if (item.hasResolved && item.value == null)
                        openSearchTextSpan('\n${Translator.t.selectAnAnime()}'),
                    ],
                  ),
                ),
              ),
              if (widget.tracker.isLoggedIn())
                Switch(
                  activeColor: Theme.of(context).primaryColor,
                  value: widget.tracker.isEnabled(widget.title, widget.plugin),
                  onChanged: (final bool enabled) async {
                    await widget.tracker
                        .setEnabled(widget.title, widget.plugin, enabled);
                    setState(() {});
                  },
                )
              else
                Icon(
                  Icons.login,
                  color: Theme.of(context)
                      .textTheme
                      .bodyText1
                      ?.color
                      ?.withOpacity(0.5),
                ),
            ],
          ),
        ),
      );
}
