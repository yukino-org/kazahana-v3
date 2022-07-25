import '../../../core/exports.dart';
import '../../exports.dart';
import 'components/exports.dart';
import 'provider.dart';

class UnderScoreHomePage extends StatefulWidget {
  const UnderScoreHomePage({
    super.key,
  });

  @override
  State<UnderScoreHomePage> createState() => _UnderScoreHomePageState();
}

class _UnderScoreHomePageState extends State<UnderScoreHomePage> {
  Future<void> showTypeModal({
    required final BuildContext context,
    required final UnderScoreHomePageProvider provider,
  }) async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(context.r.size(1))),
      ),
      builder: (final BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: context.r.size(0.5)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ...TenkaType.values.map(
              (final TenkaType x) => RadioListTile<TenkaType>(
                title: Text(x.titleCase),
                value: x,
                groupValue: provider.type,
                onChanged: (final TenkaType? type) {
                  if (type == null) return;
                  provider.setType(type);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(final BuildContext context) =>
      ChangeNotifierProvider<UnderScoreHomePageProvider>(
        create: (final _) => UnderScoreHomePageProvider()..initialize(),
        lazy: false,
        child: Consumer<UnderScoreHomePageProvider>(
          builder: (
            final BuildContext context,
            final UnderScoreHomePageProvider provider,
            final _,
          ) =>
              Scaffold(
            appBar: const UnderScoreHomePageAppBar(),
            extendBody: true,
            body: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: context.r.size(2.5)),
              child: const UnderScoreHomePageBody(),
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.r.size(1),
                vertical: context.r.size(0.5),
              ),
              child: SizedBox(
                height: context.r.size(2.5),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Builder(
                        builder: (final BuildContext context) => TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).bottomAppBarColor,
                            padding: EdgeInsets.symmetric(
                              vertical: context.r.size(0.5),
                            ),
                            surfaceTintColor: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: context.r.size(0.5)),
                              Text(provider.type.titleCase),
                              const Icon(Icons.arrow_drop_up_rounded),
                            ],
                          ),
                          onPressed: () {
                            showTypeModal(context: context, provider: provider);
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: context.r.size(0.5)),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).bottomAppBarColor,
                        borderRadius:
                            BorderRadius.circular(context.r.size(999)),
                      ),
                      child: IconTheme(
                        data: IconThemeData(
                          size: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .fontSize,
                        ),
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.search_rounded),
                              onPressed: () {
                                Navigator.of(context).pusher.pushToSearchPage();
                              },
                            ),
                            SizedBox(width: context.r.size(0.25)),
                            IconButton(
                              icon: const Icon(Icons.extension_rounded),
                              onPressed: () {
                                Navigator.of(context)
                                    .pusher
                                    .pushToModulesPage();
                              },
                            ),
                            SizedBox(width: context.r.size(0.25)),
                            IconButton(
                              icon: const Icon(Icons.settings_rounded),
                              onPressed: () {
                                Navigator.of(context)
                                    .pusher
                                    .pushToSettingsPage();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
