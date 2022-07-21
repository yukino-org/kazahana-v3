import '../../../core/exports.dart';

class ModulesPageProvider extends StatedChangeNotifier {
  final Set<String> installing = <String>{};
  final Set<String> uninstalling = <String>{};

  Future<void> install(final TenkaMetadata metadata) async {
    installing.add(metadata.id);
    notifyListeners();
    await TenkaManager.repository.install(metadata);
    if (!mounted) return;
    installing.remove(metadata.id);
    notifyListeners();
  }

  Future<void> uninstall(final TenkaMetadata metadata) async {
    uninstalling.add(metadata.id);
    notifyListeners();
    await TenkaManager.repository.uninstall(metadata);
    if (!mounted) return;
    uninstalling.remove(metadata.id);
    notifyListeners();
  }
}
