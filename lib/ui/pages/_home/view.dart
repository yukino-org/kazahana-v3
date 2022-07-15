import 'package:flutter/material.dart';
import 'package:tenka/tenka.dart';
import 'package:utilx/utils.dart';
import '../../../core/exports.dart';
import '../../router/exports.dart';

class UnderScoreHomePage extends StatefulWidget {
  const UnderScoreHomePage({
    final Key? key,
  }) : super(key: key);

  @override
  _UnderScoreHomePageState createState() => _UnderScoreHomePageState();
}

class _UnderScoreHomePageState extends State<UnderScoreHomePage> {
  TenkaType type = TenkaType.anime;

  Future<void> showTypeModal(final BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(rem(1))),
      ),
      builder: (final BuildContext context) => StatefulBuilder(
        builder: (
          final BuildContext context,
          final StateSetter setState,
        ) =>
            Padding(
          padding: EdgeInsets.symmetric(vertical: rem(0.5)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ...TenkaType.values.map(
                (final TenkaType x) => RadioListTile<TenkaType>(
                  title: Text(StringUtils.capitalize(x.name)),
                  value: x,
                  groupValue: type,
                  onChanged: (final TenkaType? type) {
                    if (type == null) return;
                    setState(() {
                      this.type = type;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            AppMeta.name,
            style: Theme.of(context).textTheme.headline4!.copyWith(
                  fontFamily: Fonts.greatVibes,
                  color: Theme.of(context).textTheme.bodyText1?.color,
                ),
          ),
        ),
        body: const Center(child: Text('Home page moment')),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: rem(1),
            vertical: rem(0.5),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Builder(
                  builder: (final BuildContext context) => TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).bottomAppBarColor,
                      padding: EdgeInsets.symmetric(vertical: rem(0.5)),
                      surfaceTintColor: Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(width: rem(0.5)),
                        Text(StringUtils.capitalize(type.name)),
                        const Icon(Icons.arrow_drop_up),
                      ],
                    ),
                    onPressed: () {
                      showTypeModal(context);
                    },
                  ),
                ),
              ),
              SizedBox(width: rem(0.5)),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).bottomAppBarColor,
                  borderRadius: BorderRadius.circular(rem(999)),
                ),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        Beamer.of(context).beamToNamed(RouteNames.search);
                      },
                    ),
                    SizedBox(width: rem(0.5)),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
