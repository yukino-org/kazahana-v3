import '../../core/exports.dart';

class RoundedBackButton extends StatelessWidget {
  const RoundedBackButton({
    super.key,
  });

  @override
  Widget build(final BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () {
          Navigator.maybePop(context);
        },
      );
}
