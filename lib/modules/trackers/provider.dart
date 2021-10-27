import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import '../state/eventer.dart';

class VolumesProgress {
  VolumesProgress({
    required final this.progress,
    required final this.total,
  });

  final int? progress;
  final int? total;
}

class Progress {
  Progress({
    required final this.progress,
    required final this.total,
    required final this.startedAt,
    required final this.completedAt,
    required final this.volumes,
  });

  final int progress;
  final int? total;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final VolumesProgress? volumes;
}

class Character {
  Character({
    required final this.name,
    required final this.role,
    required final this.image,
  });

  final String name;
  final String role;
  final String image;
}

class DetailedInfo {
  DetailedInfo({
    required final this.title,
    required final this.description,
    required final this.type,
    required final this.thumbnail,
    required final this.banner,
    required final this.status,
    required final this.progress,
    required final this.score,
    required final this.repeated,
    required final this.characters,
  });

  final String title;
  final String? description;
  final ExtensionType type;
  final String thumbnail;
  final String? banner;
  final String? status;
  final Progress progress;
  final int? score;
  final int? repeated;
  final List<Character> characters;
}

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
