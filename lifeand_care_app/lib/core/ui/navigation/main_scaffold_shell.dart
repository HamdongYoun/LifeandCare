import 'package:flutter/material.dart';
import 'package:lifeand_care_app/features/tab1_chat/chat_screen.dart';
import 'package:lifeand_care_app/features/tab2_map/map_screen.dart';
import 'package:lifeand_care_app/features/tab3_health/health_screen.dart';
import 'package:lifeand_care_app/core/ui/header/main_app_bar.dart';
import 'package:lifeand_care_app/core/ui/footer/main_bottom_nav_bar.dart';
import 'package:lifeand_care_app/core/ui/sidebar/history_drawer.dart';

class MainScaffoldShell extends StatefulWidget {
  const MainScaffoldShell({super.key});

  @override
  State<MainScaffoldShell> createState() => _MainScaffoldShellState();
}

class _MainScaffoldShellState extends State<MainScaffoldShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ChatScreen(),
    const MapScreen(),
    const HealthScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MainAppBar(),
      drawer: const HistoryDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
