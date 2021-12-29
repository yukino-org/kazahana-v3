import 'package:flutter/material.dart';
import './sections/anilist_section/view.dart';
import './sections/myanimelist_section/view.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/translator/translator.dart';

enum Pages {
  anime,
  manga,
}

class HomePage extends StatefulWidget {
  const HomePage({
    final Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Pages currentPage = Pages.values.first;
  final Map<Pages, Widget> stack = <Pages, Widget>{
    Pages.anime: Builder(
      builder: (final BuildContext context) => const MyAnimeListSection(),
    ),
  };

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: remToPx(1),
            horizontal: remToPx(1.25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Translator.t.home(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: Theme.of(context).textTheme.headline6?.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: remToPx(1),
              ),
              if (AnilistSection.enabled()) ...<Widget>[
                const AnilistSection(),
                SizedBox(height: remToPx(1)),
              ],
              stack[currentPage]!,
              SizedBox(height: remToPx(2)),
            ],
          ),
        ),
      );
}
