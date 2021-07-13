import 'package:flutter/material.dart';
import '../../core/utils.dart' as utils;
import '../../plugins/database/database.dart';

enum SettingsLabelWidgets { toggle }

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
  final void Function(dynamic) onChanged;

  SettingsLabel(
      {required this.title,
      this.desc,
      required this.icon,
      required this.type,
      required this.value,
      required this.onChanged});
}

class Page extends StatefulWidget {
  const Page({Key? key}) : super(key: key);

  @override
  State<Page> createState() => PageState();
}

class PageState extends State<Page> with SingleTickerProviderStateMixin {
  late PageController controller;

  @override
  void initState() {
    super.initState();

    controller = PageController(initialPage: 0);
  }

  Widget getSettingsWidget(SettingsLabel label) {
    switch (label.type) {
      case SettingsLabelWidgets.toggle:
        return SwitchListTile(
          title: Text(label.title),
          secondary: Icon(
            Icons.video_label,
            color: Theme.of(context).primaryColor,
          ),
          subtitle: label.desc != null ? Text(label.desc!) : null,
          value: label.value,
          activeColor: Theme.of(context).primaryColor,
          onChanged: label.onChanged,
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
            height: utils.remToPx(0.5),
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

  goToPage(int page) => controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );

  @override
  Widget build(BuildContext context) {
    final settings = DataStore.getSettings();

    final Map<SettingsCategory, List<SettingsLabel>> labels = {
      SettingsCategory(title: 'Preferences', icon: Icons.invert_colors): [
        SettingsLabel(
            title: 'Landscape Video Player',
            icon: Icons.switch_video,
            desc: 'Force auto-landscape when playing video',
            type: SettingsLabelWidgets.toggle,
            value: settings.fullscreenVideoPlayer,
            onChanged: (val) async {
              if (val is bool) {
                setState(() {
                  settings.fullscreenVideoPlayer = val;
                });
                await settings.save();
              }
            }),
      ]
    };

    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Settings',
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
