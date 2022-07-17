import 'package:utilx/utils.dart';
import '../../translator/exports.dart';

enum KitsuStatus {
  current,
  finished,
  tba,
  unreleased,
  upcoming,
}

extension KitsuStatusUtils on KitsuStatus {
  String get code => name;

  String get titleCase {
    switch (this) {
      case KitsuStatus.current:
        return Translator.t.current();

      case KitsuStatus.finished:
        return Translator.t.finished();

      case KitsuStatus.tba:
        return Translator.t.tba();

      case KitsuStatus.unreleased:
        return Translator.t.unreleased();

      case KitsuStatus.upcoming:
        return Translator.t.upcoming();
    }
  }
}

KitsuStatus parseKitsuStatus(final String code) =>
    EnumUtils.find(KitsuStatus.values, code);
