import 'dart:io';
import 'package:extensions/hetu/helpers/helpers.dart';
import '../database/database.dart';
import '../state/eventer.dart';

abstract class AppState {
  static late final ReactiveEventer<SettingsSchema> settings;

  static Future<void> initialize() async {
    settings = ReactiveEventer<SettingsSchema>(SettingsBox.get());

    settings.subscribe(
      (final SettingsSchema current, final SettingsSchema previous) {
        if (current.developers.ignoreBadHttpCertificate !=
            previous.developers.ignoreBadHttpCertificate) {
          HetuHttpClient.set(
            HetuHttpClient(
              ignoreSSLCertificate: current.developers.ignoreBadHttpCertificate,
            ),
          );
        }
      },
    );
  }

  static bool get isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
}
