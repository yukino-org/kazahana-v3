import 'package:kazahana/core/exports.dart';
import '../../exports.dart';
import 'components/exports.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

enum _SettingsCategory {
  appearance,
}

extension on _SettingsCategory {
  String getTitleCase(final Translation translations) {
    switch (this) {
      case _SettingsCategory.appearance:
        return translations.appearance;
    }
  }
}

class _SettingsPageState extends State<SettingsPage> {
  _SettingsCategory category = _SettingsCategory.appearance;

  PreferredSizeWidget buildAppBar(final BuildContext context) {
    final AppBar appBar = AppBar(
      leading: const RoundedBackButton(),
      title: Text(context.t.settings),
    );
    final double appBarHeight = appBar.preferredSize.height;
    final double height = (appBarHeight * 2) + 1;

    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: Column(
        children: <Widget>[
          appBar,
          const Divider(height: 1, thickness: 1),
          Container(
            color: Theme.of(context).bottomAppBarTheme.color,
            height: appBarHeight,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: context.r.scale(0.5)),
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: Container(
                  color: Theme.of(context).bottomAppBarTheme.color,
                  child: DropdownButton<_SettingsCategory>(
                    isExpanded: true,
                    value: category,
                    icon: const Icon(Icons.arrow_drop_down_rounded),
                    items: _SettingsCategory.values
                        .map(
                          (final _SettingsCategory x) =>
                              DropdownMenuItem<_SettingsCategory>(
                            value: x,
                            child: Text(x.getTitleCase(context.t)),
                          ),
                        )
                        .toList(),
                    onChanged: (final _SettingsCategory? value) {
                      if (value == null) return;
                      setState(() {
                        category = value;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBody(final BuildContext context) {
    switch (category) {
      case _SettingsCategory.appearance:
        return const ApperanceSettings();
    }
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: buildAppBar(context),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: AnimationDurations.defaultNormalAnimation,
            child: SingleChildScrollView(
              key: ValueKey<_SettingsCategory>(category),
              child: buildBody(context),
            ),
          ),
        ),
      );
}
