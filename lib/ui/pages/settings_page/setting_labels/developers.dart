import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import '../../../../modules/database/database.dart';
import '../../../../modules/helpers/logger.dart';
import '../../../../modules/translator/translator.dart';
import '../../../../modules/utils/function.dart';
import '../../../components/material_tiles/base.dart';
import '../../../components/material_tiles/switch.dart';

List<Widget> getSettingsDevelopers(
  final BuildContext context,
  final SettingsSchema settings,
  final Future<void> Function() save,
) =>
    <Widget>[
      MaterialTile(
        title: Text(Translator.t.copyLogsToClipboard()),
        icon: const Icon(Icons.feed),
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
      MaterialSwitchTile(
        title: Text(Translator.t.disableAnimations()),
        icon: const Icon(Icons.animation),
        value: settings.disableAnimations,
        onChanged: (final bool val) async {
          settings.disableAnimations = val;

          await save();
        },
      ),
      MaterialSwitchTile(
        title: Text(Translator.t.ignoreBadHttpSslCertificates()),
        icon: const Icon(Icons.https),
        value: settings.ignoreBadHttpCertificate,
        onChanged: (final bool val) async {
          settings.ignoreBadHttpCertificate = val;

          await save();
        },
      ),
    ];
