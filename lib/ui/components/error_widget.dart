import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:utilx/utilities/utils.dart';
import '../../modules/helpers/faces.dart';
import '../../modules/helpers/ui.dart';
import '../../modules/translator/translator.dart';

typedef ActionsBuilder = List<InlineSpan> Function(
  BuildContext,
  List<InlineSpan>,
);

class KawaiiErrorWidgetTexts {
  const KawaiiErrorWidgetTexts({
    required final this.copyError,
    required final this.copiedErrorToClipboard,
  });

  factory KawaiiErrorWidgetTexts.translated() => KawaiiErrorWidgetTexts(
        copyError: Translator.t.copyError(),
        copiedErrorToClipboard: Translator.t.copiedErrorToClipboard(),
      );

  final String copyError;
  final String copiedErrorToClipboard;
}

class KawaiiErrorWidget extends StatelessWidget {
  const KawaiiErrorWidget({
    final this.showFace = true,
    final this.child,
    final this.message,
    final this.error,
    final this.stack,
    final this.actions,
    final this.actionsBuilder,
    final this.texts,
    final this.foregroundColor = defaultForegroundColor,
    final Key? key,
  })  : assert(
          (child == null && message != null) ||
              (child != null && message == null),
        ),
        assert(
          (actionsBuilder == null && actions == null) ||
              (actionsBuilder == null && actions != null) ||
              (actionsBuilder != null && actions == null),
        ),
        super(key: key);

  factory KawaiiErrorWidget.fromErrorInfo({
    final bool showFace = true,
    final Widget? child,
    final String? message,
    final ErrorInfo? error,
    final List<InlineSpan>? actions,
    final ActionsBuilder? actionsBuilder,
    final KawaiiErrorWidgetTexts? texts,
    final Color? foregroundColor,
    final Key? key,
  }) =>
      KawaiiErrorWidget(
        key: key,
        showFace: showFace,
        message: message,
        error: error?.error,
        stack: error?.stack,
        actions: actions,
        actionsBuilder: actionsBuilder,
        texts: texts,
        foregroundColor: foregroundColor ?? defaultForegroundColor,
        child: child,
      );

  final bool showFace;
  final Widget? child;
  final String? message;
  final Object? error;
  final StackTrace? stack;
  final List<InlineSpan>? actions;
  final ActionsBuilder? actionsBuilder;
  final KawaiiErrorWidgetTexts? texts;
  final Color foregroundColor;

  InlineSpan buildCopyError(final BuildContext context) => buildActionButton(
        context: context,
        icon: const Icon(Icons.content_paste),
        child: Text(_texts.copyError),
        color: foregroundColor,
        onTap: () async {
          FlutterClipboard.copy(
            <String>[
              'Message: $message',
              if (error != null) 'Error: $error',
              if (stack != null) 'Stack trace:\n$stack',
            ].join('\n'),
          );

          FunctionUtils.withValue(
            context,
            (final BuildContext context) =>
                ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _texts.copiedErrorToClipboard,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                backgroundColor: Theme.of(context).cardColor,
              ),
            ),
          );
        },
      );

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
            if (error != null ||
                actions != null ||
                actionsBuilder != null) ...<InlineSpan>[
              WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(bottom: remToPx(0.1)),
                  child: const Text(''),
                ),
              ),
              TextSpan(
                text: '${error.toString().trim()}\n',
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: foregroundColor,
                    ),
              ),
              WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(bottom: remToPx(0.5)),
                  child: const Text(''),
                ),
              ),
              ...ListUtils.insertBetween(
                <InlineSpan>[
                  if (actions != null) ...actions!,
                  if (actionsBuilder != null)
                    ...actionsBuilder!(
                      context,
                      <InlineSpan>[
                        buildCopyError(context),
                      ],
                    )
                  else
                    buildCopyError(context),
                ],
                WidgetSpan(
                  child: SizedBox(
                    width: remToPx(0.3),
                  ),
                ),
              ),
            ],
          ],
        ),
      );

  KawaiiErrorWidgetTexts get _texts =>
      texts ?? KawaiiErrorWidgetTexts.translated();

  static const Color defaultForegroundColor = Colors.red;

  static InlineSpan buildActionButton({
    required final BuildContext context,
    required final Widget child,
    required final void Function() onTap,
    final Color? color,
    final Widget? icon,
  }) =>
      WidgetSpan(
        child: Material(
          color: color,
          type: MaterialType.button,
          child: InkWell(
            borderRadius: BorderRadius.circular(remToPx(0.2)),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: remToPx(0.3),
                vertical: remToPx(0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    IconTheme(
                      data: IconThemeData(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1
                            ?.color
                            ?.withOpacity(0.7),
                        size: Theme.of(context).textTheme.bodyText1?.fontSize,
                      ),
                      child: icon,
                    ),
                    SizedBox(
                      width: remToPx(0.3),
                    ),
                  ],
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyText1
                              ?.color
                              ?.withOpacity(0.8),
                        ),
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
