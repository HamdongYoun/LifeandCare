import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lifeand_care_app/features/tab1_chat/chat_view_model.dart';
import 'package:lifeand_care_app/features/tab1_chat/chat_screen.dart';
import 'package:lifeand_care_app/features/tab2_map/map_screen.dart';
import 'package:lifeand_care_app/features/tab3_health/health_screen.dart';
import 'package:lifeand_care_app/core/ui/header/main_app_bar.dart';
import 'package:lifeand_care_app/core/ui/footer/main_bottom_nav_bar.dart';
import 'package:lifeand_care_app/core/ui/sidebar/history_drawer.dart';
import 'package:lifeand_care_app/core/ui/overlay/components.dart';




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
    return Container(
      color: const Color(0xFFF3F4F6), // Legacy --bg-gray for outer space
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: MainAppBar(
              onLogoTap: () {
                // [Home Reset Mapping]
                setState(() => _selectedIndex = 0);
                context.read<ChatViewModel>().clearMessages();
              },
            ),
            drawer: const HistoryDrawer(),
            body: Stack(
              children: [
                IndexedStack(
                  index: _selectedIndex,
                  children: _pages,
                ),
              ],
            ),
            bottomNavigationBar: MainBottomNavBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
            ),
          ),
        ),
      ),
    );
  }
}
