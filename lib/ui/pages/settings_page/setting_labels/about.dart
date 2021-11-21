import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:utilx/utilities/utils.dart';
import '../../../../config/app.dart';
import '../../../../modules/database/database.dart';
import '../../../../modules/helpers/assets.dart';
import '../../../../modules/helpers/ui.dart';
import '../../../../modules/translator/translator.dart';
import '../../../components/material_tiles/base.dart';
import '../../../components/size_aware_builder.dart';

class _Link {
  const _Link(this.text, this.url, [this.icon = Icons.link]);

  final String url;
  final String text;
  final IconData icon;
}

final List<_Link> _links = <_Link>[
  _Link(Translator.t.website(), Config.websiteURL, Icons.language),
  _Link(Translator.t.wiki(), Config.wikiURL, Icons.article),
  _Link(Translator.t.patreon(), Config.patreonURL, Icons.favorite),
  _Link(Translator.t.reportABug(), Config.gitHubIssuesURL, Icons.bug_report),
  _Link(Translator.t.github(), Config.gitHubURL),
  _Link(Translator.t.discord(), Config.discordURL),
];

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
      ..._links.map(
        (final _Link x) => MaterialTile(
          icon: Icon(x.icon),
          title: Text(x.text),
          onTap: () async {
            await launch(x.url);
          },
        ),
      ),
    ];
