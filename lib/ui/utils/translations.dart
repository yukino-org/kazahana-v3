import 'package:kazahana/core/exports.dart';

class TranslationWrapper extends InheritedWidget {
  const TranslationWrapper({
    required this.id,
    required super.child,
    super.key,
  });

  final String id;

  @override
  bool updateShouldNotify(final TranslationWrapper oldWidget) =>
      oldWidget.id != id;

  Translation get t => Translator.currentTranslation;

  static TranslationWrapper of(final BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TranslationWrapper>()!;
}

extension TranslationWrapperUtils on BuildContext {
  Translation get t => TranslationWrapper.of(this).t;
}
