import 'package:kazahana/core/exports.dart';
import '../../../exports.dart';
import '../provider.dart';

class ViewPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ViewPageAppBar({
    super.key,
  });

  Widget buildAppBarButton({
    required final BuildContext context,
    required final Widget icon,
    required final VoidCallback onPressed,
  }) {
    final ViewPageViewProvider provider = context.watch<ViewPageViewProvider>();

    return AnimatedSwitcher(
      duration: AnimationDurations.defaultQuickAnimation,
      transitionBuilder:
          (final Widget child, final Animation<double> animation) =>
              FadeScaleTransition(animation: animation, child: child),
      child: provider.showFloatingAppBar
          ? SizedBox.square(
              dimension: context.r.scale(1.5),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .bottomAppBarTheme
                      .color!
                      .withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(context.r.scale(1)),
                  onTap: onPressed,
                  child: Center(
                    child: IconTheme(
                      data: IconThemeData(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: icon,
                    ),
                  ),
                ),
              ),
            )
          : Container(),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final ViewPageProvider provider = context.watch<ViewPageProvider>();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          top: context.r.scale(0.5),
          left: context.r.scale(0.75),
          right: context.r.scale(0.75),
        ),
        child: Row(
          children: <Widget>[
            buildAppBarButton(
              context: context,
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                Navigator.of(context).maybePop();
              },
            ),
            const Spacer(),
            if (provider.media.hasFinishedOrFailed)
              buildAppBarButton(
                context: context,
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  provider.fetch();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(0);
}
