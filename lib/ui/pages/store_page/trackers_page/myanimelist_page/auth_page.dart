import 'package:flutter/material.dart';
import '../../../../../modules/helpers/assets.dart';
import '../../../../../modules/helpers/logger.dart';
import '../../../../../modules/trackers/myanimelist/myanimelist.dart'
    as myanimelist;
import '../../../../../modules/translator/translator.dart';
import '../../../../components/trackers/auth_page.dart';
import '../../../../router.dart';

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
