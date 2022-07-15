import 'dart:io';
import 'package:path/path.dart' as path;

abstract class Paths {
  static final String rootDir = Directory.current.path;
  static final String cliDir = path.join(rootDir, 'cli');
  static final String assetsDir = path.join(rootDir, 'assets');
  static final String libDir = path.join(rootDir, 'lib');
  static final String iconsDir = path.join(assetsDir, 'images/icon');
}
