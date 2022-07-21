import '../../../../core/exports.dart';
import '../provider.dart';

class ViewPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ViewPageAppBar({
    final Key? key,
  }) : super(key: key);

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
              dimension: rem(1.5),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).bottomAppBarColor.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(rem(1)),
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
          top: rem(0.5),
          left: rem(0.75),
          right: rem(0.75),
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
  // ? Prevents excess padding with `SafeArea`
  Size get preferredSize => const Size.fromHeight(mockedHeight);

  static final double fixedHeight = rem(2);
  static const double mockedHeight = 10;
}
