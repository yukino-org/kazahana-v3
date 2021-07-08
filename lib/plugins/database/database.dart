import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class DataStoreKeys {
  static const settings = 'settings';
}

class DataStore {
  DataStore();

  Future<void> initialize() async {
    await Hive.initFlutter('yukino-app');

    await Hive.openBox(DataStoreKeys.settings);
  }

  settingsBox() {
    return Hive.box(DataStoreKeys.settings);
  }
}
