import '../../../core/exports.dart';
import '../../exports.dart';
import 'components/exports.dart';
import 'provider.dart';

class AnilistPage extends StatelessWidget {
  const AnilistPage({
    super.key,
  });

  @override
  Widget build(final BuildContext context) =>
      ChangeNotifierProvider<AnilistPageProvider>(
        create: (final _) => AnilistPageProvider()..initialize(),
        child: Consumer<AnilistPageProvider>(
          builder: (
            final BuildContext context,
            final AnilistPageProvider provider,
            final _,
          ) =>
              Scaffold(
            appBar: AppBar(title: Text(context.t.anilist())),
            body: provider.isLoggedIn
                ? AnilistPageProfileBody(provider: provider)
                : const AnilistPageLoginBody(),
          ),
        ),
      );
}
