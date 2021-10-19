import 'package:flutter/material.dart';
import '../../../../components/trackers/auth_page.dart';
import '../../../../core/trackers/myanimelist/myanimelist.dart' as myanimelist;
import '../../../../plugins/helpers/assets.dart';
import '../../../../plugins/helpers/logger.dart';
import '../../../../plugins/router.dart';
import '../../../../plugins/translator/translator.dart';

class Page extends StatelessWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) => AuthPage(
        title: Translator.t.myAnimeList(),
        logo: Assets.myAnimeListLogo,
        authenticate: () async {
          final ParsedRouteInfo args =
              ParsedRouteInfo.fromURI(ModalRoute.of(context)!.settings.name!);
          await myanimelist.MyAnimeListManager.authenticate(
            args.params['code']!,
          );
        },
        logger: Logger.of('myanimelist_page/auth_page'),
      );
}
