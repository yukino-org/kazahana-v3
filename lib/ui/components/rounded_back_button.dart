import '../../core/exports.dart';

class RoundedBackButton extends StatelessWidget {
  const RoundedBackButton({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () {
          Navigator.maybePop(context);
        },
      );
}
