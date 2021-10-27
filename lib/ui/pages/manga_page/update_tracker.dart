import '../../../modules/trackers/provider.dart';
import '../../../modules/trackers/trackers.dart';

Future<void> updateTrackers(
  final String title,
  final String plugin,
  final String _chapter,
  final String? _vol,
) async {
  final int? chapter = int.tryParse(_chapter);

  if (chapter != null) {
    final MangaProgress progress = MangaProgress(
      chapters: chapter,
      volume: _vol != null ? int.tryParse(_vol) : null,
    );

    for (final TrackerProvider<MangaProgress> provider in Trackers.manga) {
      if (provider.isLoggedIn() && provider.isEnabled(title, plugin)) {
        final ResolvedTrackerItem? item =
            await provider.getComputed(title, plugin);

        if (item != null) {
          await provider.updateComputed(
            item,
            progress,
          );
        }
      }
    }
  }
}
