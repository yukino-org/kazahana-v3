import 'package:kazahana/core/exports.dart';

class TranslationsWrapper extends InheritedWidget {
  const TranslationsWrapper({
    required this.id,
    required super.child,
    super.key,
  });

  final String id;

  @override
  bool updateShouldNotify(final TranslationsWrapper oldWidget) =>
      oldWidget.id != id;

  Translations get t => Translator.currentTranslation;

  static TranslationsWrapper of(final BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TranslationsWrapper>()!;
}

extension TranslationsWrapperUtils on BuildContext {
  Translations get t => TranslationsWrapper.of(this).t;
}
