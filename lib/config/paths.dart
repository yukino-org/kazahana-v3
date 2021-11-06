import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import './app.dart';

abstract class PathDirs {
  static late String documents;
  static late String temp;

  static Future<void> initialize() async {
    documents = path.join(
      (await path_provider.getApplicationDocumentsDirectory()).path,
      Config.code,
    );

    temp = path.join(
      (await path_provider.getTemporaryDirectory()).path,
      Config.code,
    );
  }

  static String get data => path.join(documents, 'data');

  static String get otherData => path.join(documents, 'other-data');

  static String get extensions => path.join(documents, 'extensions');
}
