import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:version/version.dart';
import '../../config.dart';
import '../helpers/eventer.dart';
import '../helpers/http_download.dart';

class UpdateInfo {
  UpdateInfo({
    required final this.release,
    required final this.version,
    required final this.path,
    required final this.size,
    required final this.date,
  });

  factory UpdateInfo.fromJson(final Map<dynamic, dynamic> json) => UpdateInfo(
        release: json['release'] as String,
        version: json['version'] as String,
        path: json['path'] as String,
        size: json['size'] as double,
        date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      );

  final String release;
  final String version;
  final String path;
  final double size;
  final DateTime date;
}

enum UpdateTypes {
  beta,
  stable,
}

extension UpdateTypesUtils on UpdateTypes {
  String get type => toString().split('.').last;
}

abstract class PlatformUpdater {
  final Eventer<DownloadProgress> progress = Eventer<DownloadProgress>();

  Future<List<UpdateInfo>> getUpdates() async {
    try {
      final Version version = Version.parse(Config.version);
      final UpdateTypes type = UpdateTypes.values.firstWhereOrNull(
            (final UpdateTypes x) => version.preRelease.contains(x.type),
          ) ??
          UpdateTypes.stable;

      final http.Response res =
          await http.get(Uri.parse(Config.updatesURL(type.type)));
      final List<UpdateInfo> updates = (json.decode(res.body) as List<dynamic>)
          .map(
            (final dynamic x) =>
                UpdateInfo.fromJson(json as Map<dynamic, dynamic>),
          )
          .toList();

      return updates
          .where(
            (final UpdateInfo x) => Version.parse(x.version) > version,
          )
          .toList();
    } catch (_) {
      return <UpdateInfo>[];
    }
  }

  Future<void> install(final UpdateInfo update);
}
