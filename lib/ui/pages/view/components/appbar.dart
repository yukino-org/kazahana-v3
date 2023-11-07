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
              FadeTransition(opacity: animation, child: child),
      child: provider.showFloatingAppBar
          ? SizedBox.square(
              dimension: context.r.scale(2),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .background
                      .withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(context.r.scale(2)),
                  onTap: onPressed,
                  child: Center(
                    child: IconTheme(
                      data: IconThemeData(
                        color: Theme.of(context).colorScheme.onBackground,
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
      child: SizedBox(
        height: preferredHeight,
        child: Row(
          children: <Widget>[
            SizedBox(width: context.r.scale(0.75)),
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
            SizedBox(width: context.r.scale(0.75)),
          ],
        ),
      ),
    );
  }

  double get preferredHeight =>
      RelativeScaleData.fromSettingsNoResponsive().scale(3.5);

  @override
  Size get preferredSize => Size.fromHeight(preferredHeight);
}
