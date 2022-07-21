import '../../core/exports.dart';

enum PageTransitionHorizontalDirection {
  left,
  right,
}

abstract class PageTransitionBuilder {
  static const Offset defaultLeftOffset = Offset(-1, 0);
  static const Offset defaultRightOffset = Offset(1, 0);

  static Offset getOffsetFromDirection(
    final PageTransitionHorizontalDirection direction, {
    required final Offset leftOffset,
    required final Offset rightOffset,
  }) {
    switch (direction) {
      case PageTransitionHorizontalDirection.left:
        return const Offset(-1, 0);

      case PageTransitionHorizontalDirection.right:
        return const Offset(1, 0);
    }
  }

  static Animation<Offset> createHorizontalOffsetAnimation({
    required final PageTransitionHorizontalDirection direction,
    required final bool reverse,
    required final Animation<double> primaryAnimation,
    required final Animation<double> secondaryAnimation,
    required final Curve curve,
    final Offset leftOffset = defaultLeftOffset,
    final Offset rightOffset = defaultRightOffset,
    final Offset toOffset = Offset.zero,
  }) {
    final Offset fromOffset = getOffsetFromDirection(
      direction,
      leftOffset: leftOffset,
      rightOffset: rightOffset,
    );
    final Offset begin = reverse ? toOffset : fromOffset;
    final Offset end = reverse ? fromOffset : toOffset;
    final Animation<double> animation =
        reverse ? secondaryAnimation : primaryAnimation;

    return Tween<Offset>(begin: begin, end: end)
        .chain(CurveTween(curve: Curves.fastOutSlowIn))
        .animate(animation);
  }
}
