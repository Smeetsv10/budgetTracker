import 'package:flutter/material.dart';
import 'package:budget_tracker/screens/homescreen.dart';
import 'package:budget_tracker/screens/labelscreen.dart';

/// ScreenManager acts as the root wrapper for navigation between main sections.
class ScreenManager extends StatefulWidget {
  const ScreenManager({super.key});

  @override
  State<ScreenManager> createState() => _ScreenManagerState();
}

class _ScreenManagerState extends State<ScreenManager> {
  int _currentIndex = 0;

  // Replace these placeholders with your actual imported screen widgets
  // (e.g., HomeScreen(), LabelManagerScreen())
  late final List<Widget> _screens = [
    const HomeScreen(),
    const LabelScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.grey[850],
          indicatorColor: const Color(0xFFD97706).withValues(alpha: 0.3),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: Color(0xFFD97706),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
            }
            return const TextStyle(color: Colors.white70, fontSize: 12);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFFD97706));
            }
            return const IconThemeData(color: Colors.white70);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.label_outlined),
              selectedIcon: Icon(Icons.label),
              label: 'Labels',
            ),
          ],
        ),
      ),
    );
  }
}
