import 'package:flutter/material.dart';
import 'home_view.dart';
import 'chat_view.dart';
import 'map_view.dart';
import 'health_profile_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),
    const ChatView(),
    const MapView(),
    const HealthProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '상담'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '지도'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}
