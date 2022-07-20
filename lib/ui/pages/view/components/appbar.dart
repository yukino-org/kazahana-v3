import '../../../../core/exports.dart';
import '../provider.dart';

class ViewPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ViewPageAppBar({
    required this.controller,
    final Key? key,
  }) : super(key: key);

  final AnimationController controller;

  Widget buildAppBarButton({
    required final BuildContext context,
    required final Widget icon,
    required final VoidCallback onPressed,
  }) =>
      AnimatedBuilder(
        animation: controller,
        builder: (final BuildContext context, final Widget? child) =>
            FadeScaleTransition(animation: controller, child: child),
        child: SizedBox.square(
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
        ),
      );

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
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).maybePop();
              },
            ),
            const Spacer(),
            buildAppBarButton(
              context: context,
              icon: const Icon(Icons.refresh),
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
  Size get preferredSize => Size.fromHeight(fixedHeight);

  static final double fixedHeight = rem(2);
}
