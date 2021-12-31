import 'package:flutter/material.dart';
import './controller.dart';
import '../../../modules/helpers/assets.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/translator/translator.dart';
import '../../components/error_widget.dart';
import '../../components/network_image_fallback.dart';
import '../../components/reactive_state_builder.dart';
import '../../components/with_child_builder.dart';
import '../../models/view.dart';
import '../../router.dart';
import 'widgets/popup.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    final Key? key,
  }) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SearchPageController controller = SearchPageController();

  @override
  void initState() {
    super.initState();

    controller.setup().then((final void _) async {
      await controller.onInitState(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    controller.ready();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  Future<void> selectPlugins(final BuildContext context) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (
        final BuildContext context,
        final Animation<double> a1,
        final Animation<double> a2,
      ) =>
          StatefulBuilder(
        builder: (final BuildContext context, final StateSetter setState) =>
            SearchExtensionsPopUp(controller: controller),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => View<SearchPageController>(
        controller: controller,
        builder: (
          final BuildContext context,
          final SearchPageController controller,
        ) =>
            Scaffold(
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.list),
            onPressed: () {
              selectPlugins(context);
            },
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: remToPx(1),
                horizontal: remToPx(1.25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Translator.t.search(),
                    style: Theme.of(context).textTheme.headline6?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextField(
                    controller: controller.searchTextController,
                    decoration: InputDecoration(
                      labelText: controller.currentPlugin != null
                          ? Translator.t.searchInPlugin(
                              controller.currentPlugin!.plugin.name,
                            )
                          : (controller.args?.autoSearch == true)
                              ? Translator.t.selectAPluginToGetResults()
                              : Translator.t.selectPlugin(),
                    ),
                    onSubmitted: (final String terms) async {
                      await controller.search();
                    },
                    enabled: controller.currentPlugin != null,
                  ),
                  SizedBox(
                    height: remToPx(1.25),
                  ),
                  ReactiveStateBuilder(
                    state: controller.results.state,
                    onWaiting: (final BuildContext context) => Center(
                      child: Text(
                        Translator.t.enterToSearch(),
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .color!
                              .withOpacity(0.7),
                        ),
                      ),
                    ),
                    onResolving: (final BuildContext context) => Padding(
                      padding: EdgeInsets.only(
                        top: remToPx(1.5),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    onResolved: (final BuildContext context) => Builder(
                      builder: (final BuildContext context) {
                        if (controller.results.value!.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.only(
                              top: remToPx(1.5),
                            ),
                            child: Center(
                              child: KawaiiErrorWidget(
                                message: Translator.t.noResultsFound(),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: UiUtils.getGridded(
                            MediaQuery.of(context).size.width.toInt(),
                            controller.results.value!
                                .map(
                                  (final SearchResult x) => Card(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(4),
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                          ParsedRouteInfo(
                                            x.plugin.type.route,
                                            x.plugin.type.constructQuery(
                                              src: x.info.url,
                                              plugin: x.plugin.plugin.id,
                                            ),
                                          ).toString(),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(remToPx(0.5)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(
                                              width: remToPx(4),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  remToPx(0.25),
                                                ),
                                                child: WithChildBuilder(
                                                  builder: (
                                                    final BuildContext context,
                                                    final Widget child,
                                                  ) =>
                                                      x.info.thumbnail != null
                                                          ? FallbackableNetworkImage(
                                                              image:
                                                                  FallbackableNetworkImageProps(
                                                                x
                                                                    .info
                                                                    .thumbnail!
                                                                    .url,
                                                                x
                                                                    .info
                                                                    .thumbnail!
                                                                    .headers,
                                                              ),
                                                              fallback: child,
                                                            )
                                                          : child,
                                                  child: Image.asset(
                                                    Assets
                                                        .placeholderImageFromContext(
                                                      context,
                                                    ),
                                                  ),
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
                                                    x.info.title,
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
                                                  Text(
                                                    x.plugin.plugin.name,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          Theme.of(context)
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
                                  ),
                                )
                                .toList(),
                          ),
                        );
                      },
                    ),
                    onFailed: (final BuildContext context) => Padding(
                      padding: EdgeInsets.only(
                        top: remToPx(1.5),
                      ),
                      child: Center(
                        child: KawaiiErrorWidget.fromErrorInfo(
                          message: Translator.t.failedToGetResults(),
                          error: controller.results.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
