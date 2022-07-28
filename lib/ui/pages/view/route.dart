import 'package:kazahana/core/exports.dart';
import '../../exports.dart';
import 'view.dart';

class ViewPageRoute extends RoutePage {
  final RegExp pattern = RegExp(r'^\/view\/(\d+)$');

  @override
  bool matches(final RouteInfo route) => pattern.hasMatch(route.name);

  int parseId(final String name) =>
      int.parse(pattern.firstMatch(name)!.group(1)!);

  @override
  Widget build(final RouteInfo route) {
    final int id = parseId(route.name);
    final AnilistMedia? media = route.data as AnilistMedia?;
    return ViewPage(mediaId: id, media: media);
  }
}

extension ViewPageRouteUtils on RoutePusher {
  Future<void> pushToViewPage({
    required final int id,
    final AnilistMedia? media,
  }) =>
      navigator.pushNamed('/view/$id', arguments: media);

  Future<void> pushToViewPageFromMedia(final AnilistMedia media) =>
      pushToViewPage(id: media.id, media: media);
}
