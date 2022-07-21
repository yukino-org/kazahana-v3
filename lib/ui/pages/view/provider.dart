import '../../../core/exports.dart';

class ViewPageViewProvider extends ChangeNotifier {
  bool showFloatingAppBar = true;

  void setFloatingAppBarVisibility({
    required final bool visible,
  }) {
    if (showFloatingAppBar != visible) {
      showFloatingAppBar = visible;
      notifyListeners();
    }
  }
}

class ViewPageProvider extends StatedChangeNotifier {
  late final int mediaId;
  final StatedValue<AnilistMedia> media = StatedValue<AnilistMedia>();

  Future<void> initialize({
    required final int id,
    final AnilistMedia? media,
  }) async {
    mediaId = id;
    if (media != null) {
      this.media.finish(media);
      await this.media.value.fetchAll();
      if (!mounted) return;
      notifyListeners();
      return;
    }

    await fetch();
  }

  Future<void> fetch() async {
    media.loading();
    notifyListeners();

    try {
      media.finish(await AnilistMediaEndpoints.fetchId(mediaId));
      await media.value.fetchAll();
    } catch (err, trace) {
      media.fail(err, trace);
    }
    if (!mounted) return;
    notifyListeners();
  }
}
