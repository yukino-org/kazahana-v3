import 'package:extensions/extensions.dart' as extensions;
import 'package:flutter/material.dart';
import './anime_list/animelist_page.dart' as animelist_page;
import '../../../../core/models/page_args/myanimelist_page.dart'
    as myanimelist_page;
import '../../../../plugins/helpers/stateful_holder.dart';
import '../../../../plugins/router.dart';

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> with DidLoadStater {
  late myanimelist_page.PageArguments args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    doLoadStateIfHasnt();
  }

  @override
  Future<void> load() async {
    args = myanimelist_page.PageArguments.fromJson(
      ParsedRouteInfo.fromURI(ModalRoute.of(context)!.settings.name!).params,
    );
  }

  Widget getPage() {
    switch (args.type) {
      case extensions.ExtensionType.anime:
        return animelist_page.Page(
          args: args,
        );

      // TODO: Manga page
      // case extensions.ExtensionType.manga:
      //   break;

      default:
        throw UnimplementedError();
    }
  }

  @override
  Widget build(final BuildContext context) => getPage();
}
