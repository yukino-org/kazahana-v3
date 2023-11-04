import 'dart:async';
import 'package:flutter/material.dart';

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
    timer?.cancel();
    tabController.dispose();

    super.dispose();
  }

  void scheduleSlideChange() {
    timer = Timer(widget.slideDuration, () {
      final int nextIndex =
          currentIndex + 1 < widget.children.length ? currentIndex + 1 : 0;
      tabController.animateTo(nextIndex, duration: widget.animationDuration);
      scheduleSlideChange();
    });
  }

  @override
  Widget build(final BuildContext context) =>
      TabBarView(controller: tabController, children: widget.children);

  int get currentIndex => tabController.index;
}
