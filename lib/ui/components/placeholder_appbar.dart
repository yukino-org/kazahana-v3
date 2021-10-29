import 'package:flutter/material.dart';

class PlaceholderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PlaceholderAppBar({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) => AppBar(
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
        elevation: 0,
        iconTheme: IconTheme.of(context).copyWith(
          color: Theme.of(context).textTheme.headline6?.color,
        ),
      );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
