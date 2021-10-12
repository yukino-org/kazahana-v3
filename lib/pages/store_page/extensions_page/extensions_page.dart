import 'package:extensions/extensions.dart' as extensions;
import 'package:flutter/material.dart';
import '../../../core/extensions.dart';
import '../../../plugins/helpers/ui.dart';
import '../../../plugins/helpers/utils/string.dart';
import '../../../plugins/translator/translator.dart';

class ExtensionsPage extends StatefulWidget {
  const ExtensionsPage({
    final Key? key,
  }) : super(key: key);

  @override
  _ExtensionsPageState createState() => _ExtensionsPageState();
}

class _ExtensionsPageState extends State<ExtensionsPage> {
  @override
  Widget build(final BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            Translator.t.extensions(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: Theme.of(context).textTheme.headline6?.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: remToPx(0.5),
          ),
          ...ExtensionsManager.store.map(
            (final extensions.ResolvableExtension ext) {
              final bool installed = ExtensionsManager.isInstalled(ext);

              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () async {
                    await showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: MaterialLocalizations.of(context)
                          .modalBarrierDismissLabel,
                      pageBuilder: (
                        final BuildContext context,
                        final Animation<double> a1,
                        final Animation<double> a2,
                      ) =>
                          SafeArea(
                        child: Dialog(
                          child: _ExtensionPopup(ext: ext),
                        ),
                      ),
                    );

                    setState(() {});
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: remToPx(0.6),
                      vertical: remToPx(0.5),
                    ),
                    child: Row(
                      children: <Widget>[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.9),
                            borderRadius: BorderRadiusDirectional.circular(
                              remToPx(0.2),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: remToPx(0.4),
                              vertical: remToPx(0.1),
                            ),
                            child: Image.network(
                              ext.image,
                              width: remToPx(1.8),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: remToPx(0.75),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: ext.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                TextSpan(
                                  text:
                                      '\n${StringUtils.capitalize(ext.type.type)}${ext.nsfw ? '(18+)' : ''}',
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                if (ext.nsfw)
                                  TextSpan(
                                    text: ' (${Translator.t.nsfw()})',
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        ?.copyWith(
                                          color: Colors.red.shade400,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (installed)
                          Padding(
                            padding: EdgeInsets.only(
                              left: remToPx(0.75),
                              right: remToPx(0.25),
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.green[400],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
}

class _ExtensionPopup extends StatefulWidget {
  const _ExtensionPopup({
    required final this.ext,
    final Key? key,
  }) : super(key: key);

  final extensions.ResolvableExtension ext;

  @override
  _ExtensionPopupState createState() => _ExtensionPopupState();
}

enum ExtensionState {
  install,
  installed,
  installing,
  uninstalling,
}

class _ExtensionPopupState extends State<_ExtensionPopup> {
  late ExtensionState status = ExtensionsManager.isInstalled(widget.ext)
      ? ExtensionState.installed
      : ExtensionState.install;

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: remToPx(1.2),
            vertical: remToPx(0.8),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width > ResponsiveSizes.sm
                ? ResponsiveSizes.sm.toDouble()
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(remToPx(0.2)),
                      child: Container(
                        height: remToPx(2.5),
                        padding: EdgeInsets.all(remToPx(0.3)),
                        color: Colors.black.withOpacity(0.9),
                        child: Image.network(widget.ext.image),
                      ),
                    ),
                    SizedBox(
                      width: remToPx(0.7),
                    ),
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: widget.ext.name,
                            style:
                                Theme.of(context).textTheme.headline6?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          TextSpan(
                            text:
                                '\n${Translator.t.by()} ${widget.ext.id.split('.').first}',
                            style: Theme.of(context).textTheme.caption,
                          ),
                          TextSpan(
                            text:
                                '\n${Translator.t.version()}: ${widget.ext.version.toString()}',
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: remToPx(0.5),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.close,
                          size: Theme.of(context).textTheme.button?.fontSize,
                        ),
                        label: Text(Translator.t.cancel()),
                      ),
                    ),
                    SizedBox(
                      width: remToPx(0.5),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: <ExtensionState>[
                          ExtensionState.install,
                          ExtensionState.installed,
                        ].contains(status)
                            ? () async {
                                if (status == ExtensionState.installed) {
                                  setState(() {
                                    status = ExtensionState.uninstalling;
                                  });

                                  await ExtensionsManager.uninstall(
                                    widget.ext,
                                  );

                                  setState(() {
                                    status = ExtensionState.install;
                                  });
                                } else if (status == ExtensionState.install) {
                                  setState(() {
                                    status = ExtensionState.installing;
                                  });

                                  await ExtensionsManager.install(
                                    widget.ext,
                                  );

                                  setState(() {
                                    status = ExtensionState.installed;
                                  });
                                }
                              }
                            : null,
                        icon: Icon(
                          <ExtensionState>[
                            ExtensionState.install,
                            ExtensionState.installing,
                          ].contains(status)
                              ? Icons.add
                              : Icons.delete,
                          size: Theme.of(context).textTheme.button?.fontSize,
                        ),
                        label: Text(
                          status == ExtensionState.install
                              ? Translator.t.install()
                              : status == ExtensionState.installed
                                  ? Translator.t.uninstall()
                                  : status == ExtensionState.installing
                                      ? Translator.t.installing()
                                      : Translator.t.uninstalling(),
                        ),
                        style: TextButton.styleFrom(
                          side: BorderSide.none,
                          primary: Colors.white,
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
