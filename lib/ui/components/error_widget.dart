import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import '../../modules/helpers/faces.dart';
import '../../modules/helpers/ui.dart';
import '../../modules/translator/translator.dart';
import '../../modules/utils/error.dart';
import '../../modules/utils/list.dart';

class KawaiiErrorWidget extends StatelessWidget {
  const KawaiiErrorWidget({
    final this.showFace = true,
    final this.child,
    final this.message,
    final this.error,
    final this.stack,
    final Key? key,
  })  : assert(
          (child == null && message != null) ||
              (child != null && message == null),
        ),
        super(key: key);

  factory KawaiiErrorWidget.fromErrorInfo({
    final bool showFace = true,
    final Widget? child,
    final String? message,
    final ErrorInfo? error,
    final Key? key,
  }) =>
      KawaiiErrorWidget(
        key: key,
        showFace: showFace,
        message: message,
        error: error?.error,
        stack: error?.stack,
        child: child,
      );

  final bool showFace;
  final Widget? child;
  final String? message;
  final Object? error;
  final StackTrace? stack;

  @override
  Widget build(final BuildContext context) => RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: <InlineSpan>[
            if (showFace) ...<InlineSpan>[
              TextSpan(
                text: '${ListUtils.random(KawaiiFaces.sad)}\n',
                style: Theme.of(context).textTheme.headline4,
              ),
              WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(bottom: remToPx(0.5)),
                  child: const Text(''),
                ),
              ),
            ],
            if (child != null) WidgetSpan(child: child!),
            if (message != null)
              TextSpan(
                text: '$message\n',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            if (error != null) ...<InlineSpan>[
              WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(bottom: remToPx(0.1)),
                  child: const Text(''),
                ),
              ),
              TextSpan(
                text: '$error\n',
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: Colors.red,
                    ),
              ),
              WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(bottom: remToPx(0.3)),
                  child: const Text(''),
                ),
              ),
              WidgetSpan(
                child: Material(
                  color: Colors.red,
                  type: MaterialType.transparency,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(remToPx(0.2)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: remToPx(0.3),
                        vertical: remToPx(0.1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.content_paste,
                            size:
                                Theme.of(context).textTheme.bodyText1?.fontSize,
                            color: Theme.of(context)
                                .textTheme
                                .bodyText1
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                          SizedBox(
                            width: remToPx(0.3),
                          ),
                          Text(
                            Translator.t.copyError(),
                            style:
                                Theme.of(context).textTheme.bodyText2?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          ?.color
                                          ?.withOpacity(0.8),
                                    ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      FlutterClipboard.copy(
                        <String>[
                          'Message: $message',
                          if (error != null) 'Error: $error',
                          if (stack != null) 'Stack trace: $stack',
                        ].join('\n'),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      );
}
