import 'package:flutter/material.dart';
import 'package:utilx/utilities/utils/error.dart';
import '../../../modules/helpers/ui.dart';
import '../../components/error_widget.dart';

// Since we don't know what failed, we will be not relying on other things
const String somethingWentWrongText = 'Something horribly went wrong.';
const KawaiiErrorWidgetTexts errorTexts = KawaiiErrorWidgetTexts(
  copyError: 'Copy Error',
  copiedErrorToClipboard: 'Copied error to clipboard.',
);

class ErrorPage extends StatelessWidget {
  const ErrorPage({
    required this.error,
    final Key? key,
  }) : super(key: key);

  final ErrorInfo error;

  @override
  Widget build(final BuildContext context) => Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(
            vertical: remToPx(1),
            horizontal: remToPx(1.25),
          ),
          child: Center(
            child: KawaiiErrorWidget.fromErrorInfo(
              message: somethingWentWrongText,
              error: error,
              texts: errorTexts,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      );
}
