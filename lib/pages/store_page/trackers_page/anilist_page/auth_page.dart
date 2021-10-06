import 'package:flutter/material.dart';
import '../../../../components/trackers/auth_page.dart';
import '../../../../core/trackers/anilist/anilist.dart' as anilist;
import '../../../../plugins/helpers/logger.dart';
import '../../../../plugins/translator/translator.dart';

class Page extends StatelessWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) => AuthPage(
        title: Translator.t.anilist(),
        authenticate: () async {
          final anilist.TokenInfo token =
              anilist.TokenInfo.fromURL(ModalRoute.of(context)!.settings.name!);

          await anilist.AnilistManager.authenticate(token);
        },
        logger: Logger.of('anilist_page/auth_page'),
      );
}
