import '../../../../core/exports.dart';
import 'tiles/exports.dart';

class ApperanceSettings extends StatefulWidget {
  const ApperanceSettings({
    final Key? key,
  }) : super(key: key);

  @override
  State<ApperanceSettings> createState() => _ApperanceSettingsState();
}

class _ApperanceSettingsState extends State<ApperanceSettings> {
  Future<void> saveSettings() async {
    await SettingsDatabase.save();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(final BuildContext context) => SettingsBodyWrapper(
        child: Column(
          children: <Widget>[
            MultiChoiceListTile<String>(
              title: Text(Translator.t.accentColor()),
              secondary: const Icon(Icons.format_color_fill_rounded),
              value: SettingsDatabase.settings.primaryColor ??
                  ThemerThemeData.defaultForeground.name,
              items: ColorPalettes.foregroundColors.asMap().map(
                    (final _, final ColorPalette x) =>
                        MapEntry<String, Widget>(x.name, Text(x.name)),
                  ),
              onChanged: (final String value) {
                SettingsDatabase.settings.primaryColor = value;
                saveSettings();
              },
            ),
            MultiChoiceListTile<String>(
              title: Text(Translator.t.backgroundColor()),
              secondary: const Icon(Icons.format_paint_rounded),
              value: SettingsDatabase.settings.backgroundColor ??
                  ThemerThemeData.defaultBackground.name,
              items: ColorPalettes.backgroundColors.asMap().map(
                    (final _, final ColorPalette x) =>
                        MapEntry<String, Widget>(x.name, Text(x.name)),
                  ),
              onChanged: (final String value) {
                SettingsDatabase.settings.backgroundColor = value;
                saveSettings();
              },
            ),
            SwitchListTile(
              title: Text(Translator.t.useSystemTheme()),
              secondary: const Icon(Icons.highlight_rounded),
              value: SettingsDatabase.settings.useSystemPreferredTheme,
              onChanged: (final bool value) {
                SettingsDatabase.settings.useSystemPreferredTheme = value;
                saveSettings();
              },
            ),
            SwitchListTile(
              title: Text(Translator.t.darkMode()),
              secondary: AnimatedSwitcher(
                duration: AnimationDurations.defaultNormalAnimation,
                child: Icon(
                  SettingsDatabase.settings.darkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  key: UniqueKey(),
                ),
              ),
              value: SettingsDatabase.settings.darkMode,
              onChanged: SettingsDatabase.settings.useSystemPreferredTheme
                  ? null
                  : (final bool value) {
                      SettingsDatabase.settings.darkMode = value;
                      saveSettings();
                    },
            ),
            CheckboxListTile(
              title: Text(Translator.t.disableAnimations()),
              secondary: const Icon(Icons.animation_rounded),
              value: SettingsDatabase.settings.disableAnimations,
              onChanged: (final bool? value) {
                if (value == null) return;
                SettingsDatabase.settings.disableAnimations = value;
                saveSettings();
              },
            ),
          ],
        ),
      );
}
