import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:mykrono/core/screens/home_screen.dart';

void main() {
  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FThemes.zinc.dark;

    return MaterialApp(
      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      theme: theme.toApproximateMaterialTheme(),
      builder: (_, child) => FAnimatedTheme(data: theme, child: child!),
      home: const FScaffold(child: MainScreenWrapper()),
    );
  }
}

class MainScreenWrapper extends StatefulWidget {
  const MainScreenWrapper({super.key});

  @override
  State<MainScreenWrapper> createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    HomeScreen(),
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text('Categories Placeholder')],
    ),
  ];


  @override
  void initState() {
    super.initState();
  }

  void _onItemPress(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      footer: FBottomNavigationBar(
        index: _selectedIndex,
        onChange: _onItemPress,
        children: const [
          FBottomNavigationBarItem(
            icon: Icon(FIcons.house),
            label: Text("Home"),
          ),
          FBottomNavigationBarItem(
            icon: Icon(FIcons.settings),
            label: Text("Settings"),
          ),
        ],
      ),
      childPad: true,
      child: _pages[_selectedIndex],
    );
  }
}
