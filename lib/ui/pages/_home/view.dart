import '../../../core/exports.dart';
import '../../exports.dart';
import 'components/exports.dart';
import 'provider.dart';

class UnderScoreHomePage extends StatelessWidget {
  const UnderScoreHomePage({
    super.key,
  });

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
            bottomNavigationBar:
                UnderScoreHomePageBottomBar(provider: provider),
          ),
        ),
      );
}
