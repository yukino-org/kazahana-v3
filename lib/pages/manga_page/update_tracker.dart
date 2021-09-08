import '../../core/models/tracker_provider.dart';
import '../../core/trackers/providers.dart';

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

    for (final TrackerProvider<MangaProgress, dynamic> provider
        in mangaProviders) {
      if (provider.isEnabled(title, plugin)) {
        final ResolvedTrackerItem<dynamic>? item =
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
