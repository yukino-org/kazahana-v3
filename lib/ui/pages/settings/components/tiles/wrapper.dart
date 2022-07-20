import '../../../../../core/exports.dart';

class SettingsBodyWrapper extends StatelessWidget {
  const SettingsBodyWrapper({
    required this.child,
    final Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(final BuildContext context) => IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.primary),
        child: child,
      );
}
