import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../config/app.dart';
import '../../../../modules/app/state.dart';
import '../../../../modules/database/database.dart';
import '../../../../modules/helpers/assets.dart';
import '../../../../modules/helpers/logger.dart';
import '../../../../modules/helpers/ui.dart';
import '../../../../modules/translator/translator.dart';
import '../../../../modules/utils/function.dart';
import '../../../components/size_aware_builder.dart';

List<Widget> getSettingsAbout(
  final BuildContext context,
  final SettingsSchema settings,
  final Future<void> Function() save,
) =>
    <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(
          vertical: remToPx(1),
          horizontal: remToPx(1.25),
        ),
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: remToPx(0.5),
              ),
              SizeAwareBuilder(
                builder: (
                  final BuildContext context,
                  final ResponsiveSize size,
                ) {
                  final Widget image = Image.asset(
                    Assets.yukinoIcon,
                    height: remToPx(5),
                  );

                  final Widget title = RichText(
                    text: TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: Config.name,
                          style: FunctionUtils.withValue(
                            Theme.of(context),
                            (final ThemeData theme) => (size.isMd
                                    ? theme.textTheme.headline4
                                    : theme.textTheme.headline5)
                                ?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: '\nv${Config.version}',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  );

                  if (size.isMd) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: remToPx(1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          image,
                          SizedBox(
                            width: remToPx(2),
                          ),
                          title,
                        ],
                      ),
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      image,
                      SizedBox(
                        height: remToPx(0.8),
                      ),
                      title,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      ListTile(
        leading: Icon(
          Icons.feed,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(Translator.t.copyLogsToClipboard()),
        onTap: () async {
          final String logs = await Logger.read();
          await FlutterClipboard.copy(logs);

          // ignore: use_build_context_synchronously
          FunctionUtils.withValue(
            context,
            (final BuildContext context) =>
                ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  Translator.t.copiedLogsToClipboard(),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                backgroundColor: Theme.of(context).cardColor,
              ),
            ),
          );
        },
      ),
    ];
