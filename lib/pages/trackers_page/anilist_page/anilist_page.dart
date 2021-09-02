import 'package:flutter/material.dart';
import '../../../core/trackers/anilist/anilist.dart' as anilist;
import '../../../plugins/helpers/stateful_holder.dart';
import '../../../plugins/helpers/ui.dart';
import '../../../plugins/helpers/utils/string.dart';
import '../../../plugins/translator/translator.dart';

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> with SingleTickerProviderStateMixin {
  StatefulHolder<anilist.UserInfo?> user =
      StatefulHolder<anilist.UserInfo?>(null);

  final List<Tab> tabs = anilist.Statuses.values
      .map(
        (final anilist.Statuses status) => Tab(
          text: StringUtils.capitalize(status.status),
        ),
      )
      .toList();

  final Widget loader = const Center(
    child: CircularProgressIndicator(),
  );

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(Duration.zero, () async {
      final anilist.UserInfo _user = await anilist.getUserInfo();
      if (mounted) {
        setState(() {
          user.resolve(_user);
        });
      }
    });
  }

  Widget getProfile(final anilist.UserInfo user) {
    final double width = MediaQuery.of(context).size.width;

    final Widget left = Material(
      shape: const CircleBorder(),
      elevation: 5,
      child: CircleAvatar(
        radius: remToPx(2.5),
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(
          user.avatarMedium,
        ),
      ),
    );

    final Widget right = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          user.name,
          style: Theme.of(context).textTheme.headline4?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          'ID: ${user.id}',
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );

    return width > ResponsiveSizes.md
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              left,
              SizedBox(width: remToPx(2)),
              Expanded(child: right),
            ],
          )
        : Column(
            children: <Widget>[
              left,
              SizedBox(height: remToPx(0.5)),
              right,
            ],
          );
  }

  @override
  Widget build(final BuildContext context) {
    final bool isLarge = MediaQuery.of(context).size.width > ResponsiveSizes.md;

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Translator.t.anilist()),
        ),
        body: user.hasResolved
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        left: remToPx(isLarge ? 3 : 1.25),
                        right: remToPx(isLarge ? 3 : 1.25),
                        top: remToPx(2),
                        bottom: remToPx(isLarge ? 2 : 1),
                      ),
                      child: getProfile(user.value!),
                    ),
                    SizedBox(height: remToPx(2)),
                    Center(
                      child: TabBar(
                        tabs: tabs,
                        labelColor:
                            Theme.of(context).textTheme.bodyText1?.color,
                        indicatorColor: Theme.of(context).primaryColor,
                        isScrollable: true,
                      ),
                    ),
                    TabBarView(
                      children: tabs,
                    ),
                  ],
                ),
              )
            : loader,
      ),
    );
  }
}
