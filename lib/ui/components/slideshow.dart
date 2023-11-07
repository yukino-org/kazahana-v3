import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kazahana/ui/components/exports.dart';

class Slideshow extends StatefulWidget {
  const Slideshow({
    required this.children,
    required this.slideDuration,
    required this.animationDuration,
    super.key,
  });

  final List<Widget> children;
  final Duration slideDuration;
  final Duration animationDuration;

  @override
  State<Slideshow> createState() => _SlideshowState();
}

class _SlideshowState extends State<Slideshow>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  Timer? timer;
  bool isDragged = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: widget.children.length,
      vsync: this,
    );
    scheduleSlideChange();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    tabController.dispose();
  }

  void scheduleSlideChange() {
    timer = Timer(widget.slideDuration, () {
      if (!isDragged) {
        final int nextIndex =
            currentIndex + 1 < widget.children.length ? currentIndex + 1 : 0;
        tabController.animateTo(nextIndex, duration: widget.animationDuration);
      }
      scheduleSlideChange();
    });
  }

  @override
  Widget build(final BuildContext context) => DraggableScrollConfiguration(
        child: NotificationListener<ScrollNotification>(
          onNotification: (final ScrollNotification x) {
            if (x is ScrollStartNotification) {
              isDragged = true;
            } else if (x is ScrollEndNotification) {
              isDragged = false;
            }
            return false;
          },
          child: TabBarView(
            controller: tabController,
            children: widget.children,
          ),
        ),
      );

  int get currentIndex => tabController.index;
}
