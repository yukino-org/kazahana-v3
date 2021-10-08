import 'package:flutter/material.dart';
import '../../plugins/helpers/eventer.dart';

final Eventer<ResolvedTrackerItem> onItemUpdateChangeNotifier =
    Eventer<ResolvedTrackerItem>();

class BaseTrackerItem {
  BaseTrackerItem({
    required final this.title,
    final this.image,
  });

  final String title;
  final String? image;
}

class ResolvableTrackerItem extends BaseTrackerItem {
  ResolvableTrackerItem({
    required final this.id,
    required final String title,
    final String? image,
  }) : super(title: title, image: image);

  final String id;
}

class ResolvedTrackerItem extends BaseTrackerItem {
  ResolvedTrackerItem({
    required final this.info,
    required final String title,
    final String? image,
  }) : super(title: title, image: image);

  final dynamic info;
}

class BaseProgress {}

class AnimeProgress extends BaseProgress {
  AnimeProgress({
    required final this.episodes,
  });

  final int episodes;
}

class MangaProgress extends BaseProgress {
  MangaProgress({
    required final this.chapters,
    required final this.volume,
  });

  final int chapters;
  final int? volume;
}

class TrackerProvider<P extends BaseProgress> {
  TrackerProvider({
    required final this.name,
    required final this.image,
    required final this.getComputed,
    required final this.getComputables,
    required final this.resolveComputed,
    required final this.updateComputed,
    required final this.isLoggedIn,
    required final this.isEnabled,
    required final this.setEnabled,
    required final this.getDetailedPage,
    required final this.isItemSameKind,
  });

  final String name;
  final String image;
  final Future<ResolvedTrackerItem?> Function(
    String title,
    String plugin, {
    bool force,
  }) getComputed;
  final Future<List<ResolvableTrackerItem>> Function(String title)
      getComputables;
  final Future<ResolvedTrackerItem> Function(
    String title,
    String plugin,
    ResolvableTrackerItem item,
  ) resolveComputed;
  final Future<void> Function(ResolvedTrackerItem item, P progress)
      updateComputed;
  final bool Function() isLoggedIn;
  final bool Function(String title, String plugin) isEnabled;
  final Future<void> Function(String title, String plugin, bool isEnabled)
      setEnabled;
  final Widget Function(BuildContext context, ResolvedTrackerItem item)
      getDetailedPage;
  final bool Function(
    ResolvedTrackerItem current,
    ResolvedTrackerItem unknown,
  ) isItemSameKind;
}
