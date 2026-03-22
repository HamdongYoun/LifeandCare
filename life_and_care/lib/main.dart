import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'ui/views/main_navigation_view.dart'; // 이후 생성 예정

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive 초기화 및 .env 로딩 로직이 여기에 들어갈 예정입니다.
  
  runApp(
    // Riverpod의 모든 기능을 사용하기 위해 ProviderScope로 감쌉니다.
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life & Care AI Chatbot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('프로젝트 구현 시작 - Riverpod MVVM 기틀 마련'),
        ),
      ),
    );
  }
}
