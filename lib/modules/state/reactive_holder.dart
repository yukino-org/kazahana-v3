import 'package:flutter/foundation.dart';

class ReactiveHolder<T> with ChangeNotifier implements ValueListenable<T> {
  ReactiveHolder(this.value);

  @override
  T value;

  void modify(final void Function() fn) {
    fn();
    notifyListeners();
  }
}
