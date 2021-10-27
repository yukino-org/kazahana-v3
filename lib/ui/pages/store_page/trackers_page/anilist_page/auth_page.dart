import 'package:flutter/material.dart';
import '../../../../../modules/helpers/assets.dart';
import '../../../../../modules/helpers/logger.dart';
import '../../../../../modules/trackers/anilist/anilist.dart';
import '../../../../../modules/translator/translator.dart';
import '../../../../components/trackers/auth_page.dart';

class Page extends StatelessWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) => AuthPage(
        title: Translator.t.anilist(),
        logo: Assets.anilistLogo,
        authenticate: () async {
          final AniListTokenInfo token =
              AniListTokenInfo.fromURL(ModalRoute.of(context)!.settings.name!);

          await AnilistManager.authenticate(token);
        },
        logger: Logger.of('anilist_page/auth_page'),
      );
}
