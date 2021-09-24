import 'package:flutter/material.dart';
import '../../plugins/helpers/eventer.dart';

final Eventer<ResolvedTrackerItem<dynamic>> onItemUpdateChangeNotifier =
    Eventer<ResolvedTrackerItem<dynamic>>();

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

class ResolvedTrackerItem<T extends Object> extends BaseTrackerItem {
  ResolvedTrackerItem({
    required final this.info,
    required final String title,
    final String? image,
  }) : super(title: title, image: image);

  final T info;
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

class TrackerProvider<P extends BaseProgress, T extends Object> {
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
  final Future<ResolvedTrackerItem<T>?> Function(String title, String plugin)
      getComputed;
  final Future<List<ResolvableTrackerItem>> Function(String title)
      getComputables;
  final Future<ResolvedTrackerItem<T>> Function(
    String title,
    String plugin,
    ResolvableTrackerItem item,
  ) resolveComputed;
  final Future<void> Function(ResolvedTrackerItem<dynamic> item, P progress)
      updateComputed;
  final bool Function() isLoggedIn;
  final bool Function(String title, String plugin) isEnabled;
  final Future<void> Function(String title, String plugin, bool isEnabled)
      setEnabled;
  final Widget Function(BuildContext context, ResolvedTrackerItem<dynamic> item)
      getDetailedPage;
  final bool Function(
    ResolvedTrackerItem<T> current,
    ResolvedTrackerItem<dynamic> unknown,
  ) isItemSameKind;
}
