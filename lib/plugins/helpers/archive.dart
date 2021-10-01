import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';

class ExtractArchiveConfig {
  ExtractArchiveConfig(this.input, this.dest);

  final String input;
  final String dest;
}

void extractArchiveSync(final ExtractArchiveConfig config) {
  extractFileToDisk(config.input, config.dest);
}

Future<void> extractArchive(final ExtractArchiveConfig config) async {
  await compute(extractArchiveSync, config);
}
