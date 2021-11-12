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
        if (current.ignoreBadHttpCertificate !=
            previous.ignoreBadHttpCertificate) {
          HetuHttpClient.set(
            HetuHttpClient(
              ignoreSSLCertificate: current.ignoreBadHttpCertificate,
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
