import 'dart:async';
import 'package:kazahana/core/exports.dart';

class AnilistPageProvider extends StatedChangeNotifier {
  StreamSubscription<AppEvent>? appEventSubscription;

  void initialize() {
    fetch();

    appEventSubscription = AppEvents.stream.listen((final AppEvent event) {
      if (mounted && event == AppEvent.anilistStateChange) {
        notifyListeners();
        fetch();
      }
    });
  }

  @override
  void dispose() {
    appEventSubscription?.cancel();

    super.dispose();
  }

  Future<void> fetch() async {}

  AnilistUser? get user => AnilistAuth.user;
  bool get isLoggedIn => user != null;
}
