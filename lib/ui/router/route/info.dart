import '../../../core/exports.dart';

class RouteInfo {
  const RouteInfo(this.settings);

  final RouteSettings settings;

  String get name => settings.name!;
  Object? get data => settings.arguments;
}
