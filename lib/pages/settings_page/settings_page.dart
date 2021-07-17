import 'package:flutter/material.dart';
import '../../core/utils.dart' as utils;
import '../../plugins/state.dart' show AppState;
import '../../plugins/database/database.dart';
import '../../plugins/translator/translator.dart';

enum SettingsLabelWidgets { toggle, radio }

class SettingsCategory {
  final String title;
  final IconData icon;

  SettingsCategory({required this.title, required this.icon});
}

class SettingsLabel {
  final String title;
  final String? desc;
  final IconData icon;
  final SettingsLabelWidgets type;
  final dynamic value;
  final Map<Object, String>? values;
  final void Function(dynamic) onChanged;

  SettingsLabel(
      {required this.title,
      this.desc,
      required this.icon,
      required this.type,
      required this.value,
      this.values,
      required this.onChanged});
}

class Page extends StatefulWidget {
  const Page({Key? key}) : super(key: key);

  @override
  State<Page> createState() => PageState();
}

class PageState extends State<Page> with SingleTickerProviderStateMixin {
  final controller = PageController(
    initialPage: 0,
    keepPage: true,
  );
  final settings = DataStore.getSettings();

  Future<void> saveSettings() async {
    await settings.save();
    AppState.settings.modify(settings);
  }

  Widget getSettingsWidget(SettingsLabel label) {
    switch (label.type) {
      case SettingsLabelWidgets.toggle:
        return SwitchListTile(
          title: Text(label.title),
          secondary: Icon(
            label.icon,
            color: Theme.of(context).primaryColor,
          ),
          subtitle: label.desc != null ? Text(label.desc!) : null,
          value: label.value,
          activeColor: Theme.of(context).primaryColor,
          onChanged: label.onChanged,
        );

      case SettingsLabelWidgets.radio:
        if (label.desc != null) throw ('Radio labels can\'t have \'desc\'');
        if (label.values == null) throw ('Radio labels must have \'values\'');

        return InkWell(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  label.icon,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.title,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.subtitle1?.fontSize,
                      ),
                    ),
                    Text(
                      label.values![label.value]!,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.subtitle2?.fontSize,
                        color: Theme.of(context).textTheme.caption?.color,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                            ),
                            child: Text(
                              Translator.t.chooseTheme(),
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          ...label.values!
                              .map(
                                (value, name) => MapEntry(
                                  value,
                                  Material(
                                    type: MaterialType.transparency,
                                    child: RadioListTile(
                                        title: Text(name),
                                        value: value,
                                        groupValue: label.value,
                                        activeColor:
                                            Theme.of(context).primaryColor,
                                        onChanged: (val) {
                                          if (label.value != value &&
                                              val != null) {
                                            label.onChanged(val);
                                            Navigator.of(context).pop();
                                          }
                                        }),
                                  ),
                                ),
                              )
                              .values
                              .toList(),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: utils.remToPx(0.6),
                                    vertical: utils.remToPx(0.3),
                                  ),
                                  child: Text(
                                    Translator.t.close(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          },
        );

      default:
        throw ('Unknown label type (\'${label.type}\')');
    }
  }

  Widget getCategoryPage(SettingsCategory cat, List<SettingsLabel> labels) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: utils.remToPx(0.25),
          ),
          ...labels
              .map((x) => Material(
                    type: MaterialType.transparency,
                    child: getSettingsWidget(x),
                  ))
              .toList()
        ],
      ),
    );
  }

  void goToPage(int page) => controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );

  @override
  Widget build(BuildContext context) {
    final Map<SettingsCategory, List<SettingsLabel>> labels = {
      SettingsCategory(
        title: Translator.t.preferences(),
        icon: Icons.invert_colors,
      ): [
        SettingsLabel(
          title: Translator.t.theme(),
          icon: Icons.palette,
          type: SettingsLabelWidgets.radio,
          value: settings.useSystemPreferredTheme
              ? 0
              : !settings.useDarkMode
                  ? 1
                  : 2,
          values: {
            0: Translator.t.systemPreferredTheme(),
            1: Translator.t.defaultTheme(),
            2: Translator.t.darkMode(),
          },
          onChanged: (val) async {
            if (val is int) {
              setState(() {
                switch (val) {
                  case 0:
                    settings.useSystemPreferredTheme = true;
                    break;

                  case 1:
                    settings.useSystemPreferredTheme = false;
                    settings.useDarkMode = false;
                    break;

                  case 2:
                    settings.useSystemPreferredTheme = false;
                    settings.useDarkMode = true;
                    break;
                }
              });
              await saveSettings();
            }
          },
        ),
        SettingsLabel(
          title: Translator.t.landscapeVideoPlayer(),
          icon: Icons.screen_lock_landscape,
          desc: Translator.t.landscapeVideoPlayerDetail(),
          type: SettingsLabelWidgets.toggle,
          value: settings.fullscreenVideoPlayer,
          onChanged: (val) async {
            if (val is bool) {
              setState(() {
                settings.fullscreenVideoPlayer = val;
              });

              await settings.save();
            }
          },
        ),
      ]
    };

    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              Translator.t.settings(),
            ),
          ),
          body: SafeArea(
            child: PageView(
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: utils.remToPx(0.25),
                      ),
                      ...labels.keys
                          .toList()
                          .asMap()
                          .map((i, x) => MapEntry(
                              i,
                              ListTile(
                                leading: Icon(
                                  x.icon,
                                  color: Theme.of(context).primaryColor,
                                ),
                                title: Text(x.title),
                                onTap: () {
                                  goToPage(i + 1);
                                },
                              )))
                          .values
                          .toList()
                    ],
                  ),
                ),
                ...labels.keys
                    .map((x) => getCategoryPage(x, labels[x]!))
                    .toList(),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          if (controller.page == 0) {
            Navigator.of(context).pop();
            return true;
          }

          goToPage(0);
          return false;
        });
  }
}
