import 'package:kazahana/core/exports.dart';

class KawaiiFace extends StatelessWidget {
  const KawaiiFace({
    required this.face,
    this.text,
    this.child,
    super.key,
  }) : assert(text != null || child != null);

  final String face;
  final String? text;
  final InlineSpan? child;

  @override
  Widget build(final BuildContext context) => RichText(
        text: TextSpan(
          children: <InlineSpan>[
            TextSpan(text: face),
            if (text != null) TextSpan(text: text),
            if (child != null) child!,
          ],
        ),
        textAlign: TextAlign.center,
      );
}
