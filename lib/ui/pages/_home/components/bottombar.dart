import '../../../../core/exports.dart';
import '../../../exports.dart';
import '../provider.dart';

class UnderScoreHomePageBottomBar extends StatelessWidget {
  const UnderScoreHomePageBottomBar({
    required this.provider,
    super.key,
  });

  final UnderScoreHomePageProvider provider;

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
                title: Text(x.getTitleCase(context.t)),
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
  }

  @override
  Widget build(final BuildContext context) => Padding(
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
                      backgroundColor: Theme.of(context).bottomAppBarColor,
                      padding: EdgeInsets.symmetric(
                        vertical: context.r.size(0.5),
                      ),
                      surfaceTintColor: Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(width: context.r.size(0.5)),
                        Text(provider.type.getTitleCase(context.t)),
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
                  borderRadius: BorderRadius.circular(context.r.size(999)),
                ),
                child: IconTheme(
                  data: IconThemeData(
                    size: Theme.of(context).textTheme.headlineMedium!.fontSize,
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
                          Navigator.of(context).pusher.pushToModulesPage();
                        },
                      ),
                      SizedBox(width: context.r.size(0.25)),
                      IconButton(
                        icon: const Icon(Icons.settings_rounded),
                        onPressed: () {
                          Navigator.of(context).pusher.pushToSettingsPage();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
