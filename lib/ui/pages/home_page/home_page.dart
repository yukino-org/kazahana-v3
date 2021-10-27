import 'package:flutter/material.dart';
import './anilist_section.dart' as anilist_section;
import './anime_section.dart' as anime_section;
import '../../../modules/helpers/ui.dart';
import '../../../modules/translator/translator.dart';

enum Pages {
  anime,
  manga,
}

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  late Pages currentPage;
  final Map<Pages, Widget> stack = <Pages, Widget>{
    Pages.anime: Builder(
      builder: (final BuildContext context) => const anime_section.Page(),
    ),
  };

  @override
  void initState() {
    super.initState();

    currentPage = Pages.values.first;
  }

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
              if (anilist_section.enabled()) ...<Widget>[
                const anilist_section.Page(),
                SizedBox(
                  height: remToPx(1),
                ),
              ],
              stack[currentPage]!,
              SizedBox(
                height: remToPx(2),
              ),
            ],
          ),
        ),
      );
}
