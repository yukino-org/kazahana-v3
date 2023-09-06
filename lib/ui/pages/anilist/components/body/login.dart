import 'package:kazahana/core/exports.dart';
import '../../../../exports.dart';

class AnilistPageLoginBody extends StatelessWidget {
  const AnilistPageLoginBody({
    super.key,
  });

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: HorizontalBodyPadding.size(context),
          vertical: MediaQuery.of(context).size.height * 0.2,
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  AppMeta.name,
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge!
                      .copyWith(fontFamily: Fonts.greatVibes),
                ),
                SizedBox(width: context.r.size(1)),
                Text(
                  '+',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .color!
                            .withOpacity(0.3),
                      ),
                ),
                SizedBox(width: context.r.size(1)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(context.r.size(0.5)),
                  child: SizedBox.square(
                    dimension: context.r.size(2.5),
                    child: Image.asset(
                      AssetPaths.anilistLogo,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.r.size(1)),
            const Divider(),
            SizedBox(height: context.r.size(1)),
            Text(
              context.t.trackYourProgressUsingAnilist(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: context.r.size(1)),
            TextButton.icon(
              icon: const Icon(Icons.login_rounded),
              label: Text(context.t.loginUsing(context.t.anilist())),
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(horizontal: context.r.size(0.75)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.r.size(0.5)),
                ),
              ),
              onPressed: () async {
                try {
                  final bool didLaunch = await launchUrl(
                    Uri.parse(AnilistAuth.oauthURL),
                    mode: LaunchMode.externalApplication,
                  );
                  if (!didLaunch) {
                    throw Exception('Failed to launch URL');
                  }
                } catch (err) {
                  Toast(
                    content: Text(err.toString()),
                  ).show();
                }
              },
            ),
          ],
        ),
      );
}
