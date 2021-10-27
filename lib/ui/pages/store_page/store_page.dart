import 'package:flutter/material.dart';
import './extensions_page/extensions_page.dart';
import './trackers_page/trackers_page.dart';
import '../../../../modules/helpers/ui.dart';

class Page extends StatelessWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

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
              const TrackersPage(),
              SizedBox(
                height: remToPx(2),
              ),
              const ExtensionsPage(),
            ],
          ),
        ),
      );
}
