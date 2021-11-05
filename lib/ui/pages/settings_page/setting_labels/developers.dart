import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import '../../../../modules/database/database.dart';
import '../../../../modules/helpers/logger.dart';
import '../../../../modules/translator/translator.dart';
import '../../../../modules/utils/function.dart';

List<Widget> getSettingsDevelopers(
  final BuildContext context,
  final SettingsSchema settings,
  final Future<void> Function() save,
) =>
    <Widget>[
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
