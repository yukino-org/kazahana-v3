import './objectbox/objectbox.g.dart';
import '../../config/paths.dart';
import '../helpers/logger.dart';

export './schemas/cache/cache.dart';
export './schemas/credentials/credentials.dart';
export './schemas/preferences/preferences.dart';
export './schemas/settings/settings.dart';

abstract class DatabaseManager {
  static late Store store;

  static Future<void> initialize() async {
    store = await openStore(directory: PathDirs.data);
    Logger.of('DataStore').info('Initialized "ObjectBox"');
  }

  static Future<void> dispose() async {
    store.close();
  }
}
