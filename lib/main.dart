import 'package:flutter/material.dart';
import './app.dart';
import './core/utils.dart' as utils;
import './plugins/state.dart' as state;

void main() => runApp(const BaseApp());

class BaseApp extends StatefulWidget {
  const BaseApp({Key? key}) : super(key: key);

  @override
  State<BaseApp> createState() => BaseAppState();
}

class BaseAppState extends State<BaseApp> {
  state.AppTheme currentTheme = state.AppTheme(true, true);

  @override
  void initState() {
    super.initState();

    state.AppState.darkMode.subscribe(handleThemeChange);
  }

  @override
  void dispose() {
    state.AppState.darkMode.unsubscribe(handleThemeChange);

    super.dispose();
  }

  void handleThemeChange(
      state.AppTheme current, state.AppTheme previous) async {
    setState(() {
      currentTheme = current;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yukino',
      theme: utils.Palette.lightTheme,
      darkTheme: utils.Palette.darkTheme,
      themeMode: currentTheme.systemPreferred
          ? ThemeMode.system
          : (currentTheme.darkMode ? ThemeMode.dark : ThemeMode.light),
      home: const App(),
    );
  }
}
