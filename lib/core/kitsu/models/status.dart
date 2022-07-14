import 'package:utilx/utils.dart';

enum KitsuStatus {
  current,
  finished,
  tba,
  unreleased,
  upcoming,
}

extension KitsuStatusUtils on KitsuStatus {
  String get code => name;
  String get titleCase => StringUtils.capitalize(name);
}

KitsuStatus parseKitsuStatus(final String code) =>
    EnumUtils.find(KitsuStatus.values, code);
