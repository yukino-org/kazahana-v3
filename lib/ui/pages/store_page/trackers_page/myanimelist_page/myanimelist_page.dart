import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import './animelist/animelist_page.dart' as animelist_page;
import './mangalist/mangalist_page.dart' as mangalist_page;
import '../../../../../modules/state/hooks.dart';
import '../../../../router.dart';

class PageArguments {
  PageArguments({
    required final this.type,
  });

  factory PageArguments.fromJson(final Map<String, String> json) {
    if (json['type'] == null) {
      throw ArgumentError("Got null value for 'type'");
    }

    return PageArguments(
      type: ExtensionType.values.firstWhere(
        (final ExtensionType type) => type.type == json['type'],
      ),
    );
  }

  ExtensionType type;

  Map<String, String> toJson() => <String, String>{
        'type': type.type,
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
  late PageArguments args;

  @override
  void initState() {
    super.initState();

    onReady(() async {
      args = PageArguments.fromJson(
        ParsedRouteInfo.fromURI(ModalRoute.of(context)!.settings.name!).params,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    maybeEmitReady();
  }

  Widget getPage() {
    switch (args.type) {
      case ExtensionType.anime:
        return animelist_page.Page(
          args: args,
        );

      case ExtensionType.manga:
        return mangalist_page.Page(
          args: args,
        );

      default:
        throw UnimplementedError();
    }
  }

  @override
  Widget build(final BuildContext context) => getPage();
}
