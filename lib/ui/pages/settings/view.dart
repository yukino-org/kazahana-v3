import '../../../core/exports.dart';
import '../../components/exports.dart';
import 'components/exports.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    final Key? key,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

enum _SettingsCategory {
  appearance,
}

extension _SettingsCategoryUtils on _SettingsCategory {
  String get titleCase {
    switch (this) {
      case _SettingsCategory.appearance:
        return Translator.t.appearance();
    }
  }
}

class _SettingsPageState extends State<SettingsPage> {
  _SettingsCategory category = _SettingsCategory.appearance;

  PreferredSizeWidget buildAppBar(final BuildContext context) {
    final AppBar appBar = AppBar(
      leading: const RoundedBackButton(),
      title: Text(Translator.t.settings()),
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
            color: Theme.of(context).bottomAppBarColor,
            height: appBarHeight,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: rem(0.5)),
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: Container(
                  color: Theme.of(context).bottomAppBarColor,
                  child: DropdownButton<_SettingsCategory>(
                    isExpanded: true,
                    value: category,
                    items: _SettingsCategory.values
                        .map(
                          (final _SettingsCategory x) =>
                              DropdownMenuItem<_SettingsCategory>(
                            value: x,
                            child: Text(x.titleCase),
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
            child: buildBody(context),
          ),
        ),
      );
}
